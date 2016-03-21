class ExternalLinksStanza < TogoStanza::Stanza::Base
  property :links do |uri|
    query("http://staging-genome.annotation.jp/sparql", <<-SPARQL.strip_heredoc)
prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#>
prefix dcat:    <http://www.w3.org/ns/dcat#>
SELECT
*
FROM <http://genome.microbedb.jp/resources/links>
WHERE
{
?gene rdfs:seeAlso ?link.
?link rdf:type ?type.
?type dcat:title ?db.
FILTER(?gene = <#{uri}>)
#FILTER(?gene = <http://genome/microbedb.jp/cyanobase/Synechocystis/genes/slr0611>)
}
    SPARQL
  end 
end
