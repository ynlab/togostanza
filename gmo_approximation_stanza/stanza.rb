class GmoApproximationStanza < TogoStanza::Stanza::Base
	SPARQL_ENDPOINT_URL = 'http://ep.dbcls.jp/sparql7ssd';
	property :debug_mode do |debug|
		(debug == "1")
	end
	property :medium_information do |medium_id|
		query = <<-SPARQL.strip_heredoc
			PREFIX gmo: <http://purl.jp/bio/11/gmo#>
			select distinct ?desc
			from <http://togogenome.org/graph/brc>
			where {
				?brc gmo:GMO_000101 "#{medium_id}" .
				?brc gmo:GMO_000102 ?desc .
			}
		SPARQL
		result = query(SPARQL_ENDPOINT_URL, query);
		if result.empty? then
			[]
		else
			result.first[:med_id] = medium_id
			result.first
		end
	end
	property :medium_score do |medium_id|
		# Score List
		query = <<-SPARQL.strip_heredoc
			PREFIX gmo: <http://purl.jp/bio/11/gmo#>
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
			select ?subject ?medium_id ?title ?index as ?index2 count(?object) as ?count2 ?original (round((2.0*?index)/(count(?object)+?original)*1000.0)/10.0) as ?score
			from <http://togogenome.org/graph/brc>
			from <http://togogenome.org/graph/gmo>
			where {
				{
					select ?subject ?medium_id ?title sum(?found) as ?index where {
					select ?subject ?medium_id ?title ?list max(?found_src) as ?found
						where {
							?key gmo:GMO_000101 "#{medium_id}" .
							?subject gmo:GMO_000101 ?medium_id .
							?subject gmo:GMO_000104 ?list .
							MINUS { ?key gmo:GMO_000104 ?list }

							?list rdfs:subClassOf* ?cla .
							filter( isURI(?cla) && ?cla in (gmo:GMO_000015,gmo:GMO_000016) )

							OPTIONAL { ?subject gmo:GMO_000102 ?title }.

							?list rdfs:label ?label .
							filter( lang(?label) != "ja" ) .

							{
								select distinct ?search_keys
								where {
									?brc gmo:GMO_000101 "#{medium_id}" .
									?brc gmo:GMO_000104 ?s .
									?s rdfs:subClassOf* ?cla .
									filter( isURI(?cla) && ?cla in (gmo:GMO_000015,gmo:GMO_000016) )
									?s rdfs:label ?label .
									filter( lang(?label) != "ja" )
									bind( replace(lcase(?label),"(monohydrate|dihydrate|trihydrate|tetrahydrate|pentahydrate|hexahydrate|hesahydrate|heptahydrate|heptaphydreate|octahydrate|nanohydrate|n-hydrate|x-hydrate)","") as ?search_keys)
								}
							} .
							bind( contains(lcase(?label),?search_keys) as ?found_src ) .
							filter( ?found_src != 0 ) .
						}
						order by ?subject ?list}
				}
				UNION {
					select ?subject ?medium_id ?title sum(?found) as ?index where {
						?key gmo:GMO_000101 "#{medium_id}" .
						?key gmo:GMO_000104 ?list .
						?list rdfs:subClassOf* ?cla .
						filter( isURI(?cla) && ?cla in (gmo:GMO_000015,gmo:GMO_000016) )
						?subject gmo:GMO_000104 ?list .
						?subject gmo:GMO_000101 ?medium_id .
						filter( ?subject != ?key )

						OPTIONAL { ?subject gmo:GMO_000102 ?title }.
						bind( 1 as ?found ) .
					}
				} .
				OPTIONAL {
					select count(distinct ?oriobj) as ?original where {
						?orisub gmo:GMO_000101 "#{medium_id}" .
						?orisub gmo:GMO_000104 ?oriobj .
						?oriobj rdfs:subClassOf* ?cla .
						filter( isURI(?cla) && ?cla in (gmo:GMO_000015,gmo:GMO_000016) )
					}
				}
				OPTIONAL {
					?subject gmo:GMO_000104 ?object .
					?object rdfs:subClassOf* ?cla .
					filter( isURI(?cla) && ?cla in (gmo:GMO_000015,gmo:GMO_000016) )
				} .
			}
			order by desc(?score) ?title
		SPARQL

		scorelist = query(SPARQL_ENDPOINT_URL, query);


		# Is Binded Undefined Components from Request Mediums
		query = <<-SPARQL.strip_heredoc
			PREFIX gmo: <http://purl.jp/bio/11/gmo#>
			select distinct count(?brc) as ?c {
				?brc gmo:GMO_000101 "#{medium_id}" .
				?brc gmo:GMO_000104 ?gmo .
				?gmo rdfs:subClassOf* gmo:GMO_000016 .
			}
		SPARQL
		is_ud = query(SPARQL_ENDPOINT_URL, query);


		# Get Undefined Components Binding List
		query = <<-SPARQL.strip_heredoc
			PREFIX gmo: <http://purl.jp/bio/11/gmo#>
			select distinct ?brc {
				?brc gmo:GMO_000104 ?gmo .
				?gmo rdfs:subClassOf* gmo:GMO_000016 .
			}
		SPARQL
		udlist = query(SPARQL_ENDPOINT_URL, query);
		udlist.map!{|item| item[:brc] }


		if is_ud.first[:c].to_i == 0 then
			# ignore undefined components
			scorelist.delete_if{|item| udlist.index(item[:subject]) }
		else
			# ignore defined components
			scorelist.delete_if{|item| udlist.index(item[:subject]) == nil }
		end

		# format number (ex. 12.0)
		scorelist.map{|item|
			item[:score] = sprintf('%.1f',item[:score])
			item
		}

		scorelist
	end
end
