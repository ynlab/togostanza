class ProteinReferencesTimelineNanoStanza < TogoStanza::Stanza::Base

  property :title do
    "Protein references timeline"
  end

  property :references do |tax_id, gene_id, step|

    refs = query('http://togostanza.org/sparql', <<-SPARQL.strip_heredoc)
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT
#?year (count(?citation) as ?count) (concat('http://www.uniprot.org/citations/?query=',group_concat(distinct replace(str(?citation), 'http://purl.uniprot.org/citations/','') ;separator='+OR+')) as ?citation_uri)
?year ?citation
FROM <http://togogenome.org/graph/uniprot/>
FROM <http://togogenome.org/graph/tgup/>
WHERE {
  <http://togogenome.org/gene/#{tax_id}:#{gene_id}> ?p ?id_upid .
  ?id_upid rdfs:seeAlso ?protein .
  ?protein a <http://purl.uniprot.org/core/Protein> .
  ?protein up:citation ?citation.
  ?citation up:date ?date.
  #?citation owl:sameAs ?same_as.
  ?citation rdf:type ?type.
  FILTER(?type = up:Journal_Citation)
  BIND(year(?date) AS ?year)
}
ORDER BY ?year
  SPARQL

  time = Time.new

  references = (1941..time.year).map{ |y|
     {year: "#{y}",citation: ""}
  }
  grouping(references.concat(refs),:year,:citation).map{ |y|
    y[:citation].delete_at(0)
    citation_uri = y[:citation].empty?  ? "" : "http://www.uniprot.org/citations/?query=#{y[:citation].map{ |c| c.sub('http://purl.uniprot.org/citations/','')}.join('+OR+')}"
    {year: "#{y[:year]}", counts: "#{y[:citation].size}", citation_uri: citation_uri , citations: "#{y[:citation]}"}
  }
  end
end
