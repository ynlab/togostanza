class ProteinEcNumberNanoStanza < TogoStanza::Stanza::Base
  property :feature do |tax_id, gene_id|
    query("http://togogenome.org/sparql", <<-SPARQL.strip_heredoc).first
      PREFIX up: <http://purl.uniprot.org/core/>
      SELECT ?ec_number
      FROM <http://togogenome.org/graph/uniprot>
      FROM <http://togogenome.org/graph/tgup>
      WHERE {
        {
          SELECT ?gene
          {
            <http://togogenome.org/gene/#{tax_id}:#{gene_id}> skos:exactMatch ?gene .
          } ORDER BY ?gene LIMIT 1
        }
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> skos:exactMatch ?gene ;
          rdfs:seeAlso ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a up:Protein .
        ?protein up:recommendedName ?recommended_name_node .
        ?recommended_name_node up:ecName ?ec_number .
      }
    SPARQL
  end
end
