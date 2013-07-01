class OrganismNameStanza < Stanza::Base
  property :organism_name_list do |tax_id|
    results = query("http://ep.dbcls.jp/sparql", <<-SPARQL.strip_heredoc)
      PREFIX go: <http://www.geneontology.org/formats/oboInOwl#>
      PREFIX ncbitaxon: <http://purl.obolibrary.org/obo/NCBITaxon_>
      PREFIX obotaxon: <http://purl.obolibrary.org/obo/ncbitaxon#>

      SELECT ?name ?name_type
      FROM <http://togogenome.org/ncbitaxon/>
      WHERE
      {
        {
          SELECT ?name ?name_type
          WHERE
          {
            ncbitaxon:#{tax_id} rdfs:label ?name .
            BIND("Scientific name" AS ?name_type)
          }
        }
        UNION
        {
          SELECT DISTINCT ?synonymTypeLabel AS ?name_type ?annotatedTarget AS ?name
          WHERE
          {
            ?blank owl:annotatedSource ncbitaxon:#{tax_id} ;
            owl:annotatedTarget ?annotatedTarget ;
            go:hasSynonymType ?synonymType
            FILTER (?synonymType != obotaxon:misspelling) .
            ?synonymType rdfs:label ?synonymTypeLabel .
          }
        }
      }
    SPARQL

    results.map {|hash|
      name_label = hash[:name_type].capitalize
      hash.merge(
        name_label: name_label
      )
    }.group_by {|hash| hash[:name_label] }.map {|hash|
       hash.last
    }
  end
end
