class GeneLengthNanoStanza < TogoStanza::Stanza::Base
  property :title do
    "Gene length"
  end

  property :result do |refseq_id, gene_id|
    query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc).first
      PREFIX rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX obo:    <http://purl.obolibrary.org/obo/>
      PREFIX faldo:  <http://biohackathon.org/resource/faldo#>
      PREFIX insdc:  <http://ddbj.nig.ac.jp/ontologies/sequence#>
      SELECT (ABS(?gene_end - ?gene_begin) + 1 AS ?gene_length)
      WHERE {
        GRAPH <http://togogenome.org/graph/tgup>
        {
          <http://togogenome.org/gene/#{refseq_id}:#{gene_id}> skos:exactMatch ?feature_uri .
        }
        GRAPH <http://togogenome.org/graph/refseq>
        {
          VALUES ?feature_type { obo:SO_0000704 obo:SO_0000252 obo:SO_0000253 } #gene, rRNA, tRNA
          ?feature_uri rdfs:subClassOf ?feature_type ;
             faldo:location ?loc .
           ?loc faldo:begin/faldo:position ?gene_begin .
           ?loc faldo:end/faldo:position ?gene_end .
        }
      }
    SPARQL
  end
end
