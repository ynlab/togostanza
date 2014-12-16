class MpoShapeStanza < TogoStanza::Stanza::Base
	SPARQL_ENDPOINT_URL = 'http://ep.dbcls.jp/sparql7ssd';

	property :features do |mpo_id|
		query = <<-SPARQL.strip_heredoc
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
			PREFIX mpo:  <http://purl.jp/bio/01/mpo#>

			SELECT distinct ?label ?definition ?altlabel
			from <http://togogenome.org/graph/mpo>
			where{
				?subject rdfs:label ?label.
				?subject rdfs:subClassOf* mpo:MPO_01000.
				OPTIONAL { ?subject skos:definition ?definition. filter(lang(?definition) != "ja") }
				OPTIONAL { ?subject skos:altLabel ?altlabel. filter(lang(?altlabel) != "ja") }
				filter(lang(?label) != "ja")
				filter(?subject = mpo:#{mpo_id})
			}
		SPARQL

		result = query(SPARQL_ENDPOINT_URL, query);

		# Create Image File Name
		imageNoData = "no_data.png"
		fileName = result.empty? ? imageNoData : (result.first[:label].downcase + ".png")
		fileName.tr!(" ","_")
		filePath = "mpo_shape_stanza/assets/mpo_shape/images/" + fileName
		unless File.exist?(filePath) then
			fileName = imageNoData
		end

		# Create Dataset
		shapes = Hash[
			:label =>       result.blank? ? "(No Data)" : result.first[:label],
			:definition =>  result.blank? ? "(No Data)" : result.first[:definition],
			:synonymlist => result.collect{|item| item[:altlabel].blank? ? "(No Data)" : item[:altlabel] },
			:image => fileName
		]
		shapes[:label]       = shapes[:label].blank?      ? "(No Data)" : shapes[:label]
		shapes[:definition]  = shapes[:definition].blank? ? "(No Data)" : shapes[:definition]
		STDERR.puts(Dir::getwd)
		STDERR.puts(shapes.inspect)
		shapes
	end
end
