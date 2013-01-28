class ProteinSequencesStanza < Stanza::Base
  property :title do |gene_id|
    "Sequences : #{gene_id}"
  end

  property :sequences do |gene_id|
    uniprot_url = query(:togogenome, <<-SPARQL).first[:up]
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX insdc: <http://rdf.insdc.org/>

      SELECT ?up
      WHERE {
        ?s insdc:feature_locus_tag "#{gene_id}" .
        ?s rdfs:seeAlso ?np .
        ?np rdf:type insdc:Protein .
        ?np rdfs:seeAlso ?up .
      }
    SPARQL

    sequences = query(:uniprot, <<-SPARQL)
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?protein ?value ?mass ?modified ?version ?checksum
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url}> .
        ?protein up:reviewed true .

        ?protein up:sequence ?seq .
        ?seq rdf:value ?value .
        ?seq up:mass ?mass .
        ?seq up:modified ?modified .
        ?seq up:version ?version .
        ?seq up:crc64Checksum ?checksum.
      }
    SPARQL

    sequences.map {|sequence|
      sequence.merge(
        sequence_length: sequence[:value].size,
        mass: ActionController::Base.helpers.number_with_delimiter(sequence[:mass].to_i)
      )
    }
  end
end
