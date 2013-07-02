class LineageInformationStanza < Stanza::Base
  property :param_tax_id do |tax_id|
   tax_id
  end

  property :tax_lineage_list do |tax_id|
    results_super = query("http://ep.dbcls.jp/sparql", <<-SPARQL.strip_heredoc)
      PREFIX taxon: <http://purl.obolibrary.org/obo/NCBITaxon_>
 
      SELECT
        REPLACE(STR(?tax) ,"http://purl.obolibrary.org/obo/NCBITaxon_" ,"" ) AS ?tax_no
        REPLACE(STR(?tax) ,"http://purl.obolibrary.org/obo/NCBITaxon_" ,"http://identifiers.org/taxonomy/" ) AS ?tax_link
        ?tax_label
        REPLACE(STR(?rank) ,"http://purl.obolibrary.org/obo/NCBITaxon_" ,"" ) AS ?rank
      WHERE
      {
        ?search_tax rdfs:label ?label FILTER (?search_tax = taxon:#{tax_id} ) .
        ?search_tax rdfs:subClassOf ?tax OPTION (transitive, t_direction 1, t_min(0), t_step("step_no") as ?step) .
        ?tax rdfs:label ?tax_label .
        OPTIONAL { ?tax <http://purl.obolibrary.org/obo/ncbitaxon#has_rank> ?rank . }
        FILTER(?tax != <http://purl.obolibrary.org/obo/NCBITaxon_1>)
      } ORDER BY DESC(?step)
    SPARQL

    results_sub = query("http://ep.dbcls.jp/sparql", <<-SPARQL.strip_heredoc)
      PREFIX taxon: <http://purl.obolibrary.org/obo/NCBITaxon_>

      SELECT 
        REPLACE(STR(?tax) ,"http://purl.obolibrary.org/obo/NCBITaxon_" ,"" ) AS ?tax_no
        REPLACE(STR(?tax) ,"http://purl.obolibrary.org/obo/NCBITaxon_" ,"http://identifiers.org/taxonomy/" ) AS ?tax_link
        ?tax_label
        REPLACE(STR(?rank) ,"http://purl.obolibrary.org/obo/NCBITaxon_" ,"" ) AS ?rank
      WHERE
      {
        ?search_tax rdfs:label ?label FILTER (?search_tax = taxon:#{tax_id} ) .
        ?tax rdfs:subClassOf ?search_tax .
        ?tax rdfs:label ?tax_label .
        OPTIONAL { ?tax <http://purl.obolibrary.org/obo/ncbitaxon#has_rank> ?rank . }
      } ORDER BY ?tax
    SPARQL

    results_super.concat(results_sub).map {|hash|
      if hash[:tax_no] == tax_id
        selected_tax = 'true'
      end
      hash.merge(
        tax_app_link: 'http://togogenome.org/organism/' + hash[:tax_no],
        selected_tax: selected_tax
      )
    }
  end
end
