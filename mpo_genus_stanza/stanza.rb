class MpoGenusStanza < TogoStanza::Stanza::Base
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
	PREFIX taxonomy:  <http://ddbj.nig.ac.jp/ontologies/taxonomy/>

	SELECT distinct ?genus ?list2 count(*) as ?cnt
	from <http://togogenome.org/graph/taxonomy>
	from <http://togogenome.org/graph/gold>
	from <http://togogenome.org/graph/mpo>
	where{
		?list rdfs:subClassOf* mpo:#{mpo_id} .
		?subject ?pre ?list .
		bind('http://identifiers.org/taxonomy/' as ?identifer) .
		filter( contains(str(?subject),?identifer) ) .

		OPTIONAL {
			?subject rdfs:subClassOf* ?list2 .
			?list2 taxonomy:rank taxonomy:Genus .
			?list2 rdfs:label ?genus
			filter( lang(?genus) != "ja" )
		}
	}
	group by ?genus ?list2
	order by desc(?cnt)
    SPARQL

    query(SPARQL_ENDPOINT_URL, query);
  end
end
