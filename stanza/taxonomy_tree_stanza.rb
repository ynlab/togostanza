class TaxonomyTreeStanza < TogoStanza::Stanza::Base
  taxon_prefix ='http://purl.obolibrary.org/obo/NCBITaxon_'

  property :selected_taxonomy_id do |tax_id|
    tax_id
  end

  property :selected_taxonomy_uri do |tax_id|
    taxon_prefix + tax_id
  end

  property :root_taxonomy_uri do
    taxon_prefix + '131567'
  end

  resource :taxonomy_tree do |tax_id|
    query('http://ep.dbcls.jp/sparql', <<-SPARQL.strip_heredoc)
      PREFIX taxon: <#{taxon_prefix}>
      PREFIX taxon_rank: <http://purl.obolibrary.org/obo/ncbitaxon#>

      SELECT ?tax ?parent ?tax_label ?rank
      FROM <http://togogenome.org/ncbitaxon/>
      WHERE
      {
        {
          ?search_tax rdfs:label ?label FILTER (?search_tax = taxon:#{tax_id} ) .
          ?search_tax rdfs:subClassOf* ?tax.
          ?tax rdfs:label ?tax_label .
          OPTIONAL { ?tax rdfs:subClassOf ?parent . }
          OPTIONAL { ?tax taxon_rank:has_rank ?rank . }
        }
        UNION
        {
          ?search_tax rdfs:label ?label FILTER (?search_tax = taxon:#{tax_id}) .
          ?tax rdfs:subClassOf ?search_tax .
          ?tax rdfs:label ?tax_label .
          OPTIONAL { ?tax rdfs:subClassOf ?parent . }
          OPTIONAL { ?tax taxon_rank:has_rank ?rank . }
        }
      }
    SPARQL
  end
end
