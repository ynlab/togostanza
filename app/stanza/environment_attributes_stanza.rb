class EnvironmentAttributesStanza < Stanza::Base
  property :environment_attr do |meo_id|
    results = query(:togogenome, <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX meo: <http://purl.jp/bio/11/meo/>

      SELECT
       REPLACE(STR(?meo_id),"http://purl.jp/bio/11/meo/","") AS ?meo_no ?meo_term_label ?meo_definition
       REPLACE(STR(?meo_superclass_id),"http://purl.jp/bio/11/meo/","") AS ?meo_superclass_no ?meo_superclass_term_label
       (sql:GROUP_DIGEST(?exact_synonym, ', ', 1000, 1)) AS ?exact_synonyms
      FROM <http://togogenome.org/graph/meo/>
      WHERE
      {
        meo:#{meo_id} rdfs:label ?meo_term_label .
        ?meo_id rdfs:label ?meo_term_label .
        OPTIONAL { ?meo_id meo:MEO_0000443 ?meo_definition . }
        OPTIONAL
        {
          ?meo_id rdfs:subClassOf ?meo_superclass_id .
          ?meo_superclass_id rdfs:label ?meo_superclass_term_label .
        }
        OPTIONAL { ?meo_id meo:MEO_0000776 ?exact_synonym . }
      } GROUP BY ?meo_id ?meo_term_label ?meo_definition ?meo_superclass_id ?meo_superclass_term_label
    SPARQL
    results.first
  end
end
