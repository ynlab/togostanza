class MpoEnvironmentStanza < TogoStanza::Stanza::Base
  SPARQL_ENDPOINT_URL = 'http://ep.dbcls.jp/sparql7ssd'

	property :general do |mpo_id|
		result = query(SPARQL_ENDPOINT_URL, <<-SPARQL.strip_heredoc)
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			PREFIX mpo:  <http://purl.jp/bio/01/mpo#>
			SELECT ?label
			WHERE {
				mpo:#{mpo_id} rdfs:label ?label.
				FILTER( LANG(?label) != "ja" )
			}
		SPARQL

		(result.nil?) ? [] : result.first
	end

  property :features do |mpo_id|
    query = <<-SPARQL.strip_heredoc
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX mpo:  <http://purl.jp/bio/01/mpo#>
      PREFIX mccv: <http://purl.jp/bio/01/mccv#>
      PREFIX meo: <http://purl.jp/bio/11/meo/>

      SELECT ?environment ?meo_id count(?subject) AS ?cnt
      FROM <http://togogenome.org/graph/taxonomy>
      FROM <http://togogenome.org/graph/gold>
      FROM <http://togogenome.org/graph/mpo>
      FROM <http://togogenome.org/graph/meo>
      WHERE{
        ?list rdfs:subClassOf* mpo:#{mpo_id} .
        ?subject ?pre ?list .
        BIND('http://identifiers.org/taxonomy/' AS ?identifer) .
        FILTER( CONTAINS(STR(?subject),?identifer) ) .
        OPTIONAL{
          ?gold mccv:MCCV_000020 ?subject .
          ?gold meo:MEO_0000437 ?meo .
          ?meo rdfs:label ?environment .
          FILTER( LANG(?environment) != "ja" )
        }
        BIND( REPLACE(STR(?meo), 'http://purl.jp/bio/11/meo/', '') AS ?meo_id )
      }
      ORDER BY DESC(?cnt)
    SPARQL

    query(SPARQL_ENDPOINT_URL, query)
  end
end
