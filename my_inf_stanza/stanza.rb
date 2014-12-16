class MyInfStanza < TogoStanza::Stanza::Base
  SPARQL_ENDPOINT_URL = 'http://ep.dbcls.jp/sparql7ssd';
  property :features do |mpo_id|
	query = <<-SPARQL.strip_heredoc
	PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	PREFIX mpo:  <http://purl.jp/bio/01/mpo#>
	PREFIX taxonomy:  <http://ddbj.nig.ac.jp/ontologies/taxonomy/>

	SELECT distinct ?subject ?taxonomy_id ?title Group_Concat(?pheno,', ') as ?pheno_merged ?genus
	from <http://togogenome.org/graph/taxonomy>
	from <http://togogenome.org/graph/gold>
	from <http://togogenome.org/graph/mpo>
	where{
		?list rdfs:subClassOf* mpo:#{mpo_id} .
		?subject ?pre ?list .
		OPTIONAL {
			?subject rdfs:subClassOf* ?list2 .
			?list2 taxonomy:rank taxonomy:Genus .
			?list2 rdfs:label ?genus .
		}
		OPTIONAL { ?subject rdfs:label ?title } .
		OPTIONAL { ?list rdfs:label ?pheno . filter( lang(?pheno) != "ja" )}
		bind('http://identifiers.org/taxonomy/' as ?identifer) .
		bind( replace(str(?subject), ?identifer, '') as ?taxonomy_id ) .
		filter( contains(str(?subject),?identifer) )
	}
	order by ?genus ?title
	SPARQL

	result = query(SPARQL_ENDPOINT_URL, query);

	# move last in empty title data
	result_empties = result.select{|item| item[:title] == nil }
	result = result.reject{|item| item[:title] == nil }
	result.concat(result_empties);

	# genus grouping
	result = result.group_by{|item| item[:genus] }
	result = result.map{|key,val| {:row_key => key, :row_value => val} }

	# move last in empty genus data
	result_empties = result.select{|item| item[:row_key] == nil }
	result = result.reject{|item| item[:row_key] == nil }
	result.concat(result_empties);

	result
  end
end
