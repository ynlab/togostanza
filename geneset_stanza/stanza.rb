class GenesetStanza < TogoStanza::Stanza::Base
  property :geneset do |uri|
    filter = uri.blank? ? '# not filtered' : "?geneset ?p <#{uri}>."

    query('http://semantic.annotation.jp/sparql', <<-SPARQL.strip_heredoc)
      SELECT
        ?geneset_label,
        ?geneset,
        REPLACE(str(?db_type), "http://genome.microbedb.jp/terms/", "") AS ?type,
        (sql:GROUP_CONCAT(?gene_label, ", ")) AS ?gene_member,
        (sql:GROUP_CONCAT(?o, ", ")) AS ?gene_urls

      WHERE {
        ?geneset ?p ?o.
        #{filter}
        ?geneset <http://genome.microbedb.jp/terms/type> ?db_type.
        ?geneset <http://www.w3.org/2000/01/rdf-schema#label> ?geneset_label.
        ?geneset a <http://www.w3.org/2004/02/skos/core#Collection>.
        FILTER(?p = <http://www.w3.org/2004/02/skos/core#member>)
        ?o <http://www.w3.org/2000/01/rdf-schema#label> ?gene_label.
      } ORDER BY ?geneset
    SPARQL
  end
end
