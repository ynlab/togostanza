class GeneLengthNanoStanza < TogoStanza::Stanza::Base
  property :title do
    "Gene length"
  end

  property :result do |tax_id, gene_id|
    query("http://togostanza.org/sparql", <<-SPARQL.strip_heredoc).first
      PREFIX rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX obo:    <http://purl.obolibrary.org/obo/>
      PREFIX faldo:  <http://biohackathon.org/resource/faldo#>
      PREFIX insdc:  <http://ddbj.nig.ac.jp/ontologies/sequence#>
      SELECT (ABS(?gene_end - ?gene_begin) + 1 AS ?gene_length)
      WHERE {
        GRAPH <http://togogenome.org/graph/refseq/> {
          ?gene insdc:locus_tag "#{gene_id}" .
          ?gene rdf:type obo:SO_0000704 .  # SO:gene
          ?gene faldo:location/faldo:begin/faldo:position ?gene_begin .
          ?gene faldo:location/faldo:end/faldo:position ?gene_end .
          ?gene faldo:location/faldo:end/faldo:reference ?seq .
          ?seq  rdfs:seeAlso <http://identifiers.org/taxonomy/#{tax_id}> .
        }
      }
    SPARQL
  end
end
