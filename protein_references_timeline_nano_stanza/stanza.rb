class ProteinReferencesTimelineNanoStanza < TogoStanza::Stanza::Base
  property :title do
    "Protein references timeline"
  end

  property :references do |refseq_id, gene_id, step|
    refs = query('http://dev.togogenome.org/sparql-test', <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>

      # "SAMPLE" for multi-year citation (publish, Epub)(e.g. <http://purl.uniprot.org/citations/20978534> up:date ?date)
      SELECT DISTINCT SAMPLE(?years) AS ?year ?citation
      FROM <http://togogenome.org/graph/uniprot>
      FROM <http://togogenome.org/graph/tgup>
      WHERE {
        <http://togogenome.org/gene/#{refseq_id}:#{gene_id}> rdfs:seeAlso ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a up:Protein ;
                 up:citation ?citation.
        ?citation up:date ?date ;
                  a up:Journal_Citation .
        BIND(year(?date) AS ?years)
      }
      ORDER BY ?year
    SPARQL

    time = Time.new

    references = (1941..time.year).map{ |y|
      {year: "#{y}",citation: ""}
    }
    grouping(references.concat(refs),:year,:citation).map{ |y|
      y[:citation].delete_at(0)
      {year: "#{y[:year]}", counts: "#{y[:citation].size}", citations: "#{y[:citation]}"}
    }
  end
end
