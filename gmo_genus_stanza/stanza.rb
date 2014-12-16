class GmoGenusStanza < TogoStanza::Stanza::Base
	property :genus_list do |medium_id|
		medium_list = query("http://ep.dbcls.jp/sparql7ssd", <<-SPARQL.strip_heredoc)
			PREFIX mccv: <http://purl.jp/bio/01/mccv#>
			PREFIX gmo: <http://purl.jp/bio/11/gmo#>
			PREFIX taxonomy:  <http://ddbj.nig.ac.jp/ontologies/taxonomy/>
			select ?genus ?list2 count(*) as ?cnt
			where {
				?gmo gmo:GMO_000101 "#{medium_id}" .
				?brc mccv:MCCV_000018 ?gmo .
				?brc mccv:MCCV_000056 ?tax .
				OPTIONAL {
					?tax rdfs:subClassOf* ?list2 .
					?list2 taxonomy:rank taxonomy:Genus .
					?list2 rdfs:label ?genus
				}
				bind('http://identifiers.org/taxonomy/' as ?identifer) .
				filter( contains(str(?tax),?identifer) )
			}
			order by desc(?cnt)
		SPARQL
	end
	property :general_information do |medium_id|
		medium_list = query("http://ep.dbcls.jp/sparql7ssd", <<-SPARQL.strip_heredoc)
			PREFIX gmo: <http://purl.jp/bio/11/gmo#>
			select ?gmo_title
			where {
				?gmo gmo:GMO_000101 "#{medium_id}" .
				?gmo gmo:GMO_000102 ?gmo_title .
			}
		SPARQL
	end
end
