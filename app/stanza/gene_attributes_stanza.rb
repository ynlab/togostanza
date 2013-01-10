class GeneAttributesStanza < StanzaBase
  def context(query_params)
    sparql = <<-SPARQL.strip_heredoc
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX faldo: <http://biohackathon.org/resource/faldo#>
      PREFIX insdc: <http://rdf.insdc.org/>
      SELECT DISTINCT ?description ?genename ?aaseq ?location ?begin ?end ?up
      WHERE {
        ?s insdc:feature_locus_tag "#{query_params[:gene_id]}" .
        ?s insdc:feature_product ?description .
        ?s insdc:feature_translation ?aaseq .
        ?s insdc:feature_gene ?genename .
        ?s rdfs:seeAlso ?x .
        ?x rdf:type insdc:Protein .
        ?x rdfs:seeAlso ?up .
        ?s faldo:location ?l .
        ?l insdc:location_string ?location .
        ?l faldo:begin ?b .
        ?b faldo:position ?begin .
        ?l faldo:end ?e .
        ?e faldo:position ?end .
        ?s obo:so_part_of+ ?seq .
        ?seq rdf:type ?seqtype .
        ?seq rdfs:seeAlso ?tax .
        ?tax rdfs:label "taxon:#{query_params[:tax_id]}" .
        ?tax rdf:type insdc:Taxonomy .
        FILTER (?seqtype IN (obo:SO_0000988, obo:SO_0000155))
      }
    SPARQL

    query('http://lod.dbcls.jp/openrdf-sesame/repositories/togogenome', sparql)
  end

  def template
    <<-EOS.strip_heredoc
      {{#each this}}
        <dl class="dl-horizontal">
          <dt>Description</dt><dd>{{description}}</dd>
          <dt>Gene Name</dt><dd>{{genename}}</dd>
          <dt>Aaseq</dt><dd>{{aaseq}}</dd>
          <dt>Location</dt><dd>{{location}}</dd>
          <dt>Begin</dt><dd>{{begin}}</dd>
          <dt>End</dt><dd>{{end}}</dd>
          <dt>Up</dt><dd>{{up}}</dd>
        </dl>
      {{/each}}
    EOS
  end
end
