class TaxonomyTreeStanza < Stanza::Base

  taxon_prefix ='http://purl.obolibrary.org/obo/NCBITaxon_';
  
  property (:selected_taxonomy_id) do |tax_id|
    "#{tax_id}"
  end
  
  property (:selected_taxonomy_uri) do |tax_id|
    taxon_prefix + "#{tax_id}"
  end
  
  property (:root_taxonomy_uri) do
    taxon_prefix + "1"
  end
  
  resource (:taxonomy_tree) do |tax_id|
    taxonomy_tree_list =  query("http://lod.dbcls.jp/openrdf-sesame5l/repositories/ncbitaxon",<<-SPARQL.strip_heredoc)
      PREFIX taxon: <#{taxon_prefix}>

      SELECT ?tax ?parent ?tax_label ?rank
      WHERE 
      {
        {
          ?search_tax rdfs:label ?label FILTER (?search_tax = taxon:#{tax_id} ) .
          ?search_tax rdfs:subClassOf* ?tax .
          ?tax rdfs:label ?tax_label .
          OPTIONAL { ?tax rdfs:subClassOf ?parent . }
          OPTIONAL { ?tax <http://purl.obolibrary.org/obo/ncbitaxon#has_rank> ?rank . }
        }
        UNION
        {
          ?tax rdfs:subClassOf taxon:#{tax_id} ; 
            rdfs:label ?tax_label .
          OPTIONAL { ?tax rdfs:subClassOf ?parent . }
          OPTIONAL { ?tax <http://purl.obolibrary.org/obo/ncbitaxon#has_rank> ?rank . }
        }
      }
    SPARQL
  end
end
