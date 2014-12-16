class GmoAppliedSpicesStanza < TogoStanza::Stanza::Base
	property :applied_spices_list do |medium_id|
		medium_list = query("http://ep.dbcls.jp/sparql7ssd", <<-SPARQL.strip_heredoc)
			PREFIX mccv: <http://purl.jp/bio/01/mccv#>
			PREFIX gmo: <http://purl.jp/bio/11/gmo#>
			select ?gmo_title ?label ?tax ?taxonomy_id
			where {
				?gmo gmo:GMO_000101 "#{medium_id}" .
				?gmo gmo:GMO_000102 ?gmo_title .
				?brc mccv:MCCV_000018 ?gmo .
				?brc mccv:MCCV_000056 ?tax .
				OPTIONAL { ?tax rdfs:label ?label . }
				bind('http://identifiers.org/taxonomy/' as ?identifer) .
				bind( replace(str(?tax), ?identifer, '') as ?taxonomy_id ) .
				filter( contains(str(?tax),?identifer) )
			}
			order by ?label
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
