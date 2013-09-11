class OrganismCultureCollectionsStanza < Stanza::Base
  property :strain_list do |tax_id|
    results = query(:togogenome, <<-SPARQL.strip_heredoc)
      PREFIX mccv: <http://purl.jp/bio/01/mccv#>
      PREFIX taxid: <http://identifiers.org/taxonomy/>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      PREFIX dc: <http://purl.org/dc/elements/1.1/>
      PREFIX taxo: <http://ddbj.nig.ac.jp/ontologies/taxonomy#>

      SELECT ?strain_id AS ?strain_url ?strain_no ?strain_name 
        ?isolated_from ?history ?application 
        (sql:GROUP_DIGEST(?other_link, ', ', 1000, 1)) AS ?other_collections
      FROM <http://togogenome.org/graph/taxonomy/> 
      FROM <http://togogenome.org/graph/brc/>
      WHERE 
      {
        { SELECT DISTINCT ?strain_id
          {
            VALUES ?related_type { mccv:MCCV_000056 mccv:MCCV_000022 mccv:MCCV_000057 mccv:MCCV_000023}
            ?strain_id ?related_type taxid:#{tax_id} .
          }
        }
        OPTIONAL { ?strain_id mccv:MCCV_000010 ?strain_no . }
        OPTIONAL { ?strain_id mccv:MCCV_000012 ?strain_name . }
        OPTIONAL { ?strain_id mccv:MCCV_000030 ?isolated_from . }
        OPTIONAL { ?strain_id mccv:MCCV_000027 ?history . }
        OPTIONAL { ?strain_id mccv:MCCV_000033 ?application . }
        OPTIONAL { ?strain_id mccv:MCCV_000024/mccv:MCCV_000026 ?other_link . }
      } GROUP BY ?strain_id ?strain_no ?strain_name ?isolated_from ?history ?application
    SPARQL
  end
end
