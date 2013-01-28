class ProteinReferencesStanza < Stanza::Base
  property :title do |gene_id|
    "References : #{gene_id}"
  end

  property :references do |gene_id|
    uniprot_url = query(:togogenome, <<-SPARQL).first[:up]
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX insdc: <http://rdf.insdc.org/>

      SELECT ?up
      WHERE {
        ?s insdc:feature_locus_tag "#{gene_id}" .
        ?s rdfs:seeAlso ?np .
        ?np rdf:type insdc:Protein .
        ?np rdfs:seeAlso ?up .
      }
    SPARQL

    references = query(:uniprot, <<-SPARQL)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

      SELECT DISTINCT ?pmid ?title (GROUP_CONCAT(DISTINCT ?author; SEPARATOR=",") AS ?authors) ?date ?name ?pages ?volume ?same
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url}> .
        ?protein up:reviewed true .

        ?protein up:citation ?citation .
        ?citation skos:exactMatch ?pmid .
        FILTER regex (str(?pmid), "pubmed")

        ?citation up:title ?title .
        ?citation up:author ?author .
        ?citation up:date ?date .
        ?citation up:name ?name .
        ?citation up:pages ?pages .
        ?citation up:volume ?volume .
        ?citation <http://www.w3.org/2002/07/owl#sameAs> ?same
      }
      GROUP BY ?pmid ?title ?date ?name ?pages ?volume ?same
      ORDER BY ?date
    SPARQL
  end
end
