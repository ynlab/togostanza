class ProteinSequenceStanza < TogoStanza::Stanza::Base
  property :sequences do |tax_id, gene_id|
    sequences = query("http://ep.dbcls.jp/sparql7upd2", <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT ?protein ?value ?mass ?modified ?version ?checksum
      FROM <http://togogenome.org/graph/uniprot/>
      FROM <http://togogenome.org/graph/tgup/>
      WHERE {
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> ?p ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a <http://purl.uniprot.org/core/Protein> ;   
          up:sequence ?seq .

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
