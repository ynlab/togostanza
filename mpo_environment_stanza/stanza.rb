class MpoEnvironmentStanza < TogoStanza::Stanza::Base
  SPARQL_ENDPOINT_URL = 'http://ep.dbcls.jp/sparql7ssd';
	property :general do |mpo_id|
		result = query(SPARQL_ENDPOINT_URL, <<-SPARQL.strip_heredoc)
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			PREFIX mpo:  <http://purl.jp/bio/01/mpo#>
			select ?label
			where {
				mpo:#{mpo_id} rdfs:label ?label.
				filter( lang(?label) != "ja" )
			}
		SPARQL

		(result.first == nil) ? [] : result.first
	end
  property :features do |mpo_id|
    query = <<-SPARQL.strip_heredoc
	PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	PREFIX mpo:  <http://purl.jp/bio/01/mpo#>
	PREFIX mccv: <http://purl.jp/bio/01/mccv#>
	PREFIX meo: <http://purl.jp/bio/11/meo/>

	SELECT ?environment ?meo_id count(?subject) as ?cnt
	from <http://togogenome.org/graph/taxonomy>
	from <http://togogenome.org/graph/gold>
	from <http://togogenome.org/graph/mpo>
	from <http://togogenome.org/graph/meo>
	where{
		?list rdfs:subClassOf* mpo:#{mpo_id} .
		?subject ?pre ?list .
		bind('http://identifiers.org/taxonomy/' as ?identifer) .
		filter( contains(str(?subject),?identifer) ) .
		OPTIONAL{
			?gold mccv:MCCV_000020 ?subject .
			?gold meo:MEO_0000437 ?meo .
			?meo rdfs:label ?environment .
			filter( lang(?environment) != "ja" )
		}
		bind( replace(str(?meo), 'http://purl.jp/bio/11/meo/', '') as ?meo_id )
	}
	order by desc(?cnt)
    SPARQL

    query(SPARQL_ENDPOINT_URL, query);
  end
end
