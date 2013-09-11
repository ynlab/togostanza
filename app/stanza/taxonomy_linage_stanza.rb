class TaxonomyLinageStanza < Stanza::Base
  taxon_prefix ='http://identifiers.org/taxonomy/'

  property :selected_taxonomy_id do |tax_id|
    tax_id
  end

  property :selected_taxonomy_uri do |tax_id|
    taxon_prefix + tax_id
  end

  property :root_taxonomy_uri do
    taxon_prefix + '131567' #cellular organisms
  end

  resource :taxonomy_tree do |tax_id|
    query(:togogenome, <<-SPARQL.strip_heredoc)
      PREFIX taxo: <http://ddbj.nig.ac.jp/ontologies/taxonomy#>
      PREFIX taxid: <#{taxon_prefix}>
      
      SELECT ?tax ?parent ?tax_label ?rank
      FROM <http://togogenome.org/graph/taxonomy/>
      WHERE
      {
        {
          ?search_tax rdfs:label ?label FILTER (?search_tax = taxid:#{tax_id} ) .
          ?search_tax rdfs:subClassOf* ?tax.
          ?tax rdfs:label ?tax_label .
          OPTIONAL { ?tax rdfs:subClassOf ?parent . }
          OPTIONAL { ?tax taxo:rank ?rank . }
        }
        UNION
        {
          ?search_tax rdfs:label ?label FILTER (?search_tax = taxid:#{tax_id}) .
          ?tax rdfs:subClassOf ?search_tax .
          ?tax rdfs:label ?tax_label .
          OPTIONAL { ?tax rdfs:subClassOf ?parent . }
          OPTIONAL { ?tax taxo:rank ?rank . }
        }
      }
    SPARQL
  end
end
