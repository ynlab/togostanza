class ProtainAttributesStanza < StanzaBase
  property :attributes do |gene_id|
    protain_attributes = query(:uniprot, <<-SPARQL)
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?sequence ?fragment ?existence_label
      WHERE {
        ?target up:locusName "#{gene_id}" .
        ?id up:encodedBy ?target .

        # Sequence length
        ?id up:sequence ?seq .
        ?seq rdf:value ?sequence .
        # need?
        # FILTER regex (?id, "uniprot")

        #Sequence status
        OPTIONAL {
          ?seq up:fragment ?fragment .
        }

        ?id up:existence ?existence .
        ?existence rdfs:label ?existence_label .
      }
    SPARQL

    protain_attributes.map do |protain_attribute|
      new_hash = Hash[protain_attribute]
      # こういうロジックをこっちに持つのはどうなんだろう?
      # でも,UniProt では取れ無さそう(?)
      # 要ご相談
      new_hash[:sequence_length] = protain_attribute[:sequence].length
      new_hash[:sequence_status] = sequence_status(protain_attribute[:fragment].to_s)
      new_hash
    end
  end

  private

  def sequence_status(fragment)
    case fragment
    when 'single', 'multiple'
      'Fragment'
    else
      'Complete'
    end
  end
end
