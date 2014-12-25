class MpoShapeStanza < TogoStanza::Stanza::Base
	SPARQL_ENDPOINT_URL = 'http://togogenome.org/sparql'

	property :features do |mpo_id|
		query = <<-SPARQL.strip_heredoc
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			PREFIX mpo:  <http://purl.jp/bio/01/mpo#>

			SELECT distinct ?label ?definition ?altlabel
			FROM <http://togogenome.org/graph/mpo>
			WHERE {
				?subject rdfs:label ?label .
				?subject rdfs:subClassOf* mpo:MPO_01000 .
				OPTIONAL { ?subject skos:definition ?definition . FILTER(LANG(?definition) != "ja") }
				OPTIONAL { ?subject skos:altLabel ?altlabel . FILTER(LANG(?altlabel) != "ja") }
				FILTER(LANG(?label) != "ja")
				FILTER(?subject = mpo:#{mpo_id})
			}
		SPARQL

		result = query(SPARQL_ENDPOINT_URL, query);

		# Create Image File Name
		image_no_data = "no_data.png"
		file_name = result.empty? ? image_no_data : (result.first[:label].downcase + ".png")
		file_name.tr!(" ","_")
		file_path = "mpo_shape_stanza/assets/mpo_shape/images/" + file_name
		file_name = image_no_data unless File.exist?(file_path)

		# Create Dataset
		shapes = Hash[
			label:       result.empty? ? "(No Data)" : result.first[:label],
			definition:  result.empty? ? "(No Data)" : result.first[:definition],
			synonymlist: result.collect {|item| item[:altlabel].nil? ? "(No Data)" : item[:altlabel] },
			image:       file_name
		]
		shapes[:label]       = shapes[:label].nil?      ? "(No Data)" : shapes[:label]
		shapes[:definition]  = shapes[:definition].nil? ? "(No Data)" : shapes[:definition]
		shapes
	end
end
