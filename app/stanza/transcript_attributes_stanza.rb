class TranscriptAttributesStanza < StanzaBase
  def context(gene_id)
    sparql  = SPARQL::Client.new('http://lod.dbcls.jp/openrdf-sesame/repositories/rdfgenome')
    results = sparql.query <<-SPARQL.strip_heredoc
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX faldo: <http://biohackathon.org/resource/faldo#>
      SELECT DISTINCT ?begin_position ?end_position
      WHERE {
        ?s rdfs:label "#{gene_id}" .
        ?s faldo:location ?location .
        ?location faldo:begin ?begin .
        ?begin faldo:position ?begin_position .
        ?location faldo:end ?end .
        ?end faldo:position ?end_position .
      }
    SPARQL
  end

  TEMPLATE = <<-EOS.strip_heredoc
    {{#each context}}
      <dl class="dl-horizontal">
        <dt>Begin Position</dt><dd>{{begin_position.value}}</dd>
        <dt>End Position</dt><dd>{{end_position.value}}</dd>
      </dl>
    {{/each}}
  EOS
end
