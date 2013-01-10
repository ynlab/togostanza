class TranscriptAttributesStanza < StanzaBase
  def context(query_params)
    sparql = <<-SPARQL.strip_heredoc
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX faldo: <http://biohackathon.org/resource/faldo#>
      SELECT DISTINCT ?begin_position ?end_position
      WHERE {
        ?s rdfs:label "#{query_params[:gene_id]}" .
        ?s faldo:location ?location .
        ?location faldo:begin ?begin .
        ?begin faldo:position ?begin_position .
        ?location faldo:end ?end .
        ?end faldo:position ?end_position .
      }
    SPARQL

    query('http://lod.dbcls.jp/openrdf-sesame/repositories/togogenome', sparql)
  end

  def template
    <<-EOS.strip_heredoc
      {{#each this}}
        <dl class="dl-horizontal">
          <dt>Begin Position</dt><dd>{{begin_position}}</dd>
          <dt>End Position</dt><dd>{{end_position}}</dd>
        </dl>
      {{/each}}
    EOS
  end
end
