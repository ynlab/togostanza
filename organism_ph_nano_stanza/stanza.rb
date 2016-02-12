class OrganismPhNanoStanza < TogoStanza::Stanza::Base
  property :ph_info do |tax_id|
    query("http://togogenome.org/sparql", <<-SPARQL.strip_heredoc)
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX mpo: <http://purl.jp/bio/01/mpo#>
      PREFIX tax: <http://identifiers.org/taxonomy/>

      SELECT DISTINCT ?min_ph ?opt_ph ?max_ph
      FROM <http://togogenome.org/graph/mpo>
      FROM <http://togogenome.org/graph/gold>
      WHERE {
        OPTIONAL {
          tax:#{tax_id} mpo:MPO_10006 ?min_ph .
        }
        OPTIONAL {
          tax:#{tax_id} mpo:MPO_10005 ?opt_ph .
        }
        OPTIONAL {
          tax:#{tax_id} mpo:MPO_10007 ?max_ph .
        }
      }
    SPARQL
  end
end
