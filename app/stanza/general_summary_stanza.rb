class GeneralSummaryStanza < StanzaBase
  def context(gene_id)
    sparql  = SPARQL::Client.new('http://lod.dbcls.jp/openrdf-sesame/repositories/rdfgenome')
    results = sparql.query <<-SPARQL.strip_heredoc
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

  TEMPLATE = <<-EOS.strip_heredoc
    {{#each context}}
      <dl class="dl-horizontal">
        <dt>Feature Product</dt><dd>{{feature_product.value}}</dd>
        <dt>Feature Gene</dt><dd>{{feature_gene.value}}</dd>
        <dt>Feature Gene Synonym</dt><dd>{{feature_gene_synonym.value}}</dd>
      </dl>
    {{/each}}
  EOS
end
