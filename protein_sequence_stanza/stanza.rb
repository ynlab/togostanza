class ProteinSequenceStanza < TogoStanza::Stanza::Base
  property :sequences do |refseq_id, gene_id|
    sequences = query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?up_id ?value ?mass ?modified ?version ?checksum
      FROM <http://togogenome.org/graph/uniprot>
      FROM <http://togogenome.org/graph/tgup>
      WHERE {
        <http://togogenome.org/gene/#{refseq_id}:#{gene_id}> rdfs:seeAlso ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a up:Protein ;
                 up:sequence ?isoform .

        # (P42166 & P42167) x (P42166-1 & P42167-1) => P42166 - P42166-1, P42167 - P42167-1
        BIND( REPLACE( STR(?protein), "http://purl.uniprot.org/uniprot/", "") AS ?up_id)
        FILTER( REGEX(?isoform, ?up_id))

        ?isoform rdf:value ?value ;
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
        # up_id: protein.split('/').last
      )
    }
  end
end
