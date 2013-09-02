class ProteinReferencesStanza < TogoStanza::Stanza::Base
  property :references do |tax_id, gene_id|
    references = query(:uniprot, <<-SPARQL.strip_heredoc)
      PREFIX up:   <http://purl.uniprot.org/core/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>
      PREFIX dct:   <http://purl.org/dc/terms/>

      SELECT DISTINCT ?pmid ?title (GROUP_CONCAT(?author, ", ") AS ?authors) ?date ?name ?pages ?volume ?same
      WHERE {
        GRAPH <http://togogenome.org/graph/> {
          <http://togogenome.org/uniprot/> dct:isVersionOf ?g .
        }

        GRAPH ?g {
          ?protein up:organism  taxonomy:#{tax_id} ;
                   rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .

          ?protein  up:citation     ?citation .
          ?citation skos:exactMatch ?pmid .
          FILTER    REGEX (STR(?pmid), "pubmed") .

          ?citation up:title   ?title ;
                    up:author  ?author ;
                    up:date    ?date ;
                    up:name    ?name ;
                    up:pages   ?pages ;
                    up:volume  ?volume ;
                    owl:sameAs ?same .
        }
      }
      GROUP BY ?pmid ?title ?date ?name ?pages ?volume ?same
      ORDER BY ?date
    SPARQL
  end
end
