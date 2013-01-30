class ProteinReferencesStanza < Stanza::Base
  property :title do |gene_id|
    "References : #{gene_id}"
  end

  property :references do |gene_id|
    references = query(:uniprot, <<-SPARQL)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

      SELECT DISTINCT ?pmid ?title (GROUP_CONCAT(DISTINCT ?author; SEPARATOR=", ") AS ?authors) ?date ?name ?pages ?volume ?same
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> ;
                 up:reviewed true .

        ?protein up:citation ?citation .
        ?citation skos:exactMatch ?pmid .
        FILTER regex (str(?pmid), "pubmed") .

        ?citation up:title ?title ;
                  up:author ?author ;
                  up:date ?date ;
                  up:name ?name ;
                  up:pages ?pages ;
                  up:volume ?volume ;
                  owl:sameAs ?same .
      }
      GROUP BY ?pmid ?title ?date ?name ?pages ?volume ?same
      ORDER BY ?date
    SPARQL
  end
end
