class ProteinEcNumberNanoStanza < TogoStanza::Stanza::Base
  property :feature do |refseq_id, gene_id|
    query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc).first
      PREFIX up: <http://purl.uniprot.org/core/>
      SELECT ?ec_number
      FROM <http://togogenome.org/graph/uniprot>
      FROM <http://togogenome.org/graph/tgup>
      WHERE {
        <http://togogenome.org/gene/#{refseq_id}:#{gene_id}> rdfs:seeAlso ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a up:Protein .
        ?protein up:recommendedName ?recommended_name_node .
        ?recommended_name_node up:ecName ?ec_number .
      }
    SPARQL
  end
end
