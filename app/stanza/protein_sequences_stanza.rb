class ProteinSequencesStanza < Stanza::Base
  property :title do |gene_id|
    "Sequences : #{gene_id}"
  end

  property :sequences do |gene_id|
    sequences = query(:uniprot, <<-SPARQL)
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?protein ?value ?mass ?modified ?version ?checksum
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> ;
                 up:reviewed true .

        ?protein up:sequence ?seq .
        ?seq rdf:value ?value ;
             up:mass ?mass ;
             up:modified ?modified ;
             up:version ?version ;
             up:crc64Checksum ?checksum .
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
