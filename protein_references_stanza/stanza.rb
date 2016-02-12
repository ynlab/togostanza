class ProteinReferencesStanza < TogoStanza::Stanza::Base
  property :references do |tax_id, gene_id|
    query("http://togogenome.org/sparql", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX up:   <http://purl.uniprot.org/core/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

      SELECT DISTINCT ?pmid ?title (GROUP_CONCAT(?author, ", ") AS ?authors) ?date ?name ?pages ?volume ?same
      FROM <http://togogenome.org/graph/uniprot>
      FROM <http://togogenome.org/graph/tgup>
      WHERE {
        {
          SELECT ?gene
          {
            <http://togogenome.org/gene/#{tax_id}:#{gene_id}> skos:exactMatch ?gene .
          } ORDER BY ?gene LIMIT 1
        }
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> skos:exactMatch ?gene ;
          rdfs:seeAlso ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a up:Protein ;
                 up:citation ?citation .
        ?citation skos:exactMatch ?pmid .
        FILTER    REGEX (STR(?pmid), "pubmed") .

        ?citation up:title   ?title ;
                  up:author  ?author ;
                  up:date    ?date ;
                  up:name    ?name ;
                  up:pages   ?pages ;
                  up:volume  ?volume ;
                  foaf:primaryTopicOf ?same .
      }
      GROUP BY ?pmid ?title ?date ?name ?pages ?volume ?same
      ORDER BY ?date
    SPARQL
  end
end
