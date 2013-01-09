class GeneralSummaryStanza < StanzaBase
  def context(query_params)
    query = <<-SPARQL.strip_heredoc
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX insdc: <http://rdf.insdc.org/>
      SELECT DISTINCT ?feature_product ?feature_gene ?feature_gene_synonym
      WHERE {
        ?s rdfs:label "#{query_params[:gene_id]}" .
        ?s insdc:feature_product ?feature_product .
        OPTIONAL {
          ?s insdc:feature_gene  ?feature_gene .
          ?s insdc:feature_gene_synonym  ?feature_gene_synonym .
        }
      }
    SPARQL

    sparql('http://lod.dbcls.jp/openrdf-sesame/repositories/togogenome', query)
  end

  def template
    <<-EOS.strip_heredoc
      {{#each this}}
        <dl class="dl-horizontal">
          <dt>Feature Product</dt><dd>{{feature_product}}</dd>
          <dt>Feature Gene</dt><dd>{{feature_gene}}</dd>
          <dt>Feature Gene Synonym</dt><dd>{{feature_gene_synonym}}</dd>
        </dl>
      {{/each}}
    EOS
  end
end
