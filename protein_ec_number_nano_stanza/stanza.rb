class ProteinEcNumberNanoStanza < TogoStanza::Stanza::Base
  property :feature do |tax_id, gene_id|
    query("http://togostanza.org/sparql", <<-SPARQL.strip_heredoc).first
      PREFIX core: <http://purl.uniprot.org/core/>
      PREFIX up: <http://purl.uniprot.org/uniprot/>
      SELECT ?ec_number
      FROM <http://togogenome.org/graph/uniprot/>
      FROM <http://togogenome.org/graph/tgup/>
      WHERE {
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> ?p ?id_upid .
        ?id_upid rdfs:seeAlso ?up .
        ?up a core:Protein .
        ?up core:recommendedName ?recommended_name_node .
        ?recommended_name_node core:ecName ?ec_number .
      }
    SPARQL
  end
end
