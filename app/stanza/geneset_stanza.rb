class GenesetStanza < Stanza::Base
    property :title do
        "GeneSet"
    end

    property :gene_id do |uri|
        uri ||='/all'
        uri.empty? ? uri.rpartition("/").last : ''
    end 

    property :geneset do |uri|
        uri ||= ''
        filter = uri.empty? ? "#?geneset ?p <#{uri}>." : "?geneset ?p <#{uri}>."

        #query("http://localhost:8890/sparql", <<-SPARQL.strip_heredoc)
        query("http://semantic.annotation.jp/sparql", <<-SPARQL.strip_heredoc)
select
?geneset_label, ?geneset, replace(str(?db_type),"http://genome.microbedb.jp/terms/","") as ?type, (sql:GROUP_CONCAT(?gene_label, ", ")) as ?gene_member, (sql:GROUP_CONCAT(?o, ", ")) as ?gene_urls
where 
{
?geneset ?p ?o.
#?geneset ?p <http://genome.microbedb.jp/cyanobase/Synechocystis/genes/sll0520>.
#{filter}
?geneset <http://genome.microbedb.jp/terms/type> ?db_type.
?geneset <http://www.w3.org/2000/01/rdf-schema#label> ?geneset_label.
?geneset a <http://www.w3.org/2004/02/skos/core#Collection>.
Filter(?p = <http://www.w3.org/2004/02/skos/core#member>)
?o <http://www.w3.org/2000/01/rdf-schema#label> ?gene_label.
} order by ?geneset
#limit 300
SPARQL
    end
end 
