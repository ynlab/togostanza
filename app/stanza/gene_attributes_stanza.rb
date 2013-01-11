class GeneAttributesStanza < StanzaBase
  variable :sequeces do |gene_id, tax_id|
    query(:refseq, <<-SPARQL)
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX faldo: <http://biohackathon.org/resource/faldo#>
      PREFIX insdc: <http://rdf.insdc.org/>
      SELECT DISTINCT ?description ?genename ?aaseq ?location ?begin ?end ?up
      WHERE {
        ?s insdc:feature_locus_tag "#{gene_id}" .
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
        ?tax rdfs:label "taxon:#{tax_id}" .
        ?tax rdf:type insdc:Taxonomy .
        FILTER (?seqtype IN (obo:SO_0000988, obo:SO_0000155))
      }
    SPARQL
  end
end