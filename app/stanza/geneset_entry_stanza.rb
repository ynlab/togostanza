class GenesetEntryStanza < Stanza::Base
  property :predicate_label do |p|
    p || 'p'
  end

  property :object_label do |o|
    o || 'o'
  end

  property :geneset_entry do |uri|
    query('http://semantic.annotation.jp/sparql', <<-SPARQL.strip_heredoc)
      SELECT
        ?p AS ?predicate,
        ?o AS ?object
      WHERE {
        <#{uri}> ?p ?o.
      }
    SPARQL
  end
end
