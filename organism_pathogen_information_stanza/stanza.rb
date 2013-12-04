class OrganismPathogenInformationStanza < TogoStanza::Stanza::Base
  property :pathogen_list do |tax_id|
    results = query("http://ep.dbcls.jp/sparql7upd2", <<-SPARQL.strip_heredoc)
      PREFIX pdo: <http://purl.jp/bio/11/pdo/>
      PREFIX taxid: <http://identifiers.org/taxonomy/>

      SELECT (REPLACE(STR(?tax_id),"http://identifiers.org/taxonomy/","") AS ?tax_no)
       ?bacterialName (GROUP_CONCAT(?diseaseName; SEPARATOR = ", ") AS ?diseaseNameSet) ?infectiousType ?strainType
      FROM <http://togogenome.org/graph/pdo/>
      FROM <http://togogenome.org/graph/pdo_mapping/>
      FROM <http://togogenome.org/graph/taxonomy/>
      WHERE
      {
        { ?tax_id rdfs:subClassOf+ taxid:#{tax_id} }
        UNION
        { ?tax_id rdfs:label ?o FILTER (?tax_id = taxid:#{tax_id}) }
        ?tax_id rdfs:label ?bacterialName ;
          pdo:isAssociatedTo ?blank .
        ?blank ?p ?disease FILTER (?p IN(pdo:mayCaused, pdo:isRelatedTo)).
        ?disease rdfs:label ?diseaseName .
        OPTIONAL { ?tax_id pdo:isAssociatedTo/pdo:infectiousType ?infectiousType . }
        OPTIONAL { ?tax_id pdo:isAssociatedTo/pdo:strainType ?strainType . }
      }
    SPARQL
    results.map {|hash|
      hash.merge(
        tax_link: "http://togogenome.org/organism/" + hash[:tax_no]
      )
    }
  end
end
