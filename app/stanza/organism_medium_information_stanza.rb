class OrganismMediumInformationStanza < Stanza::Base
  property :medium_information do |tax_id|
    results = query("http://biointegra.jp/sparqlTOGOdev", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX mccv: <http://purl.jp/bio/01/mccv#>
      PREFIX gmo: <http://purl.jp/bio/11/gmo#>
      PREFIX taxid: <http://identifiers.org/taxonomy/>
 
      SELECT ?medium_id ?medium_name STR(?medium_type_label) AS ?medium_type
        STR(?ingredient_type_label) AS ?ingredient_type
        (sql:GROUP_DIGEST(?ingredient_label , ',  ', 1000, 1)) AS ?ingredients
      FROM <http://togogenome.org/graph/brc/>
      FROM <http://togogenome.org/graph/gmo/>
      WHERE 
      {
        { SELECT DISTINCT ?medium
          {
            ?strain_id mccv:MCCV_000056 taxid:#{tax_id} .
            ?strain_id mccv:MCCV_000018 ?medium . 
          }
        }
        ?medium gmo:GMO_000101 ?medium_id .
        ?medium gmo:GMO_000111 ?medium_type .
        ?medium_type rdfs:label ?medium_type_label .
        OPTIONAL
        {
          ?medium gmo:GMO_000104 ?ingredient .
          ?ingredient rdfs:subClassOf ?ingredient_type .
          ?ingredient_type rdfs:label ?ingredient_type_label .
          ?ingredient rdfs:label ?ingredient_label FILTER (lang(?ingredient_label) = "en").
        }
        OPTIONAL { ?medium gmo:GMO_000102 ?medium_name }. 
      } GROUP BY ?ingredient_type_label ?medium_id  ?medium_name ?medium_type_label

    SPARQL

    results.reverse.group_by {|hash| hash[:medium_id] }.map {|hash| hash.last }
  end
end
