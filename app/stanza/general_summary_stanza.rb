class GeneralSummaryStanza < StanzaBase
  def context(gene_id)
    query(:refseq, <<-SPARQL.strip_heredoc)
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX insdc: <http://rdf.insdc.org/>
      SELECT DISTINCT ?feature_product ?feature_gene ?feature_gene_synonym
      WHERE {
        ?s rdfs:label "#{gene_id}" .
        ?s insdc:feature_product ?feature_product .
        OPTIONAL {
          ?s insdc:feature_gene  ?feature_gene .
          ?s insdc:feature_gene_synonym  ?feature_gene_synonym .
        }
      }
    SPARQL
  end
end
