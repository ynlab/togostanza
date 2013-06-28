class ProteinSequencesStanza < Stanza::Base
  property :sequences do |tax_id, gene_id|
    sequences = query(:uniprot, <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>
      PREFIX dct:   <http://purl.org/dc/terms/>

      SELECT DISTINCT ?protein ?value ?mass ?modified ?version ?checksum
      WHERE {
        GRAPH <http://togogenome.org/graph/> {
          <http://togogenome.org/uniprot/> dct:isVersionOf ?g .
        }

        GRAPH ?g {
          ?protein up:organism  taxonomy:#{tax_id} ;
                   rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .

          ?protein up:sequence ?seq .
          ?seq rdf:value ?value ;
               up:mass ?mass ;
               up:modified ?modified ;
               up:version ?version ;
               up:crc64Checksum ?checksum .
        }
      }
    SPARQL

    sequences.map {|hash|
      value, protein = hash.values_at(:value, :protein)

      hash.merge(
        sequence_length: value.size,
        # 'http://purl.uniprot.org/uniprot/P72587' => 'P72587'
        up_id: protein.split('/').last
      )
    }
  end
end
