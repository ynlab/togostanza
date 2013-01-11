class TranscriptAttributesStanza < StanzaBase
  variable :transcripts do |gene_id|
    query(:refseq, <<-SPARQL)
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
end
