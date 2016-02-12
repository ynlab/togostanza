class OrganismPathogenInformationStanza < TogoStanza::Stanza::Base
  property :pathogen_list do |tax_id|
    results = query("http://togogenome.org/sparql", <<-SPARQL.strip_heredoc)
      PREFIX pdo: <http://purl.jp/bio/11/pdo/>
      PREFIX taxid: <http://identifiers.org/taxonomy/>

      SELECT (REPLACE(STR(?tax_id),"http://identifiers.org/taxonomy/","") AS ?tax_no)
       ?bacterialName (GROUP_CONCAT(DISTINCT ?diseaseName; SEPARATOR = ", ") AS ?diseaseNameSet) ?infectiousType ?strainType
      WHERE
      {
        GRAPH <http://togogenome.org/graph/taxonomy> {
          ?tax_id rdfs:subClassOf* taxid:#{tax_id} .
          ?tax_id rdfs:label ?bacterialName .
        }
        GRAPH <http://togogenome.org/graph/pdo_mapping> {
          ?tax_id pdo:isAssociatedTo ?blank .
          ?blank ?p ?disease FILTER (?p IN(pdo:mayCaused, pdo:isRelatedTo)).
          OPTIONAL { ?tax_id pdo:isAssociatedTo/pdo:infectiousType ?infectiousType . }
          OPTIONAL { ?tax_id pdo:isAssociatedTo/pdo:strainType ?strainType . }
        }
        GRAPH <http://togogenome.org/graph/pdo> {
          ?disease rdfs:label ?diseaseName .
        }
      }
    SPARQL
    results.map {|hash|
      hash.merge(
        tax_link: "http://togogenome.org/organism/" + hash[:tax_no]
      )
    }
  end
end
