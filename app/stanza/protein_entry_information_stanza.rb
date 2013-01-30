class ProteinEntryInformationStanza < Stanza::Base
  property :title do |gene_id|
    "Entry information : #{gene_id}"
  end

  property :information do |gene_id|
    informations = query(:uniprot, <<-SPARQL).first
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?protein ?entry_name ?created ?modified ?sequence_modified ?version ?sequence_version ?reviewed ?status
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .
        ?protein up:reviewed true .

        ?protein up:mnemonic ?entry_name ;
                 up:created  ?created ;
                 up:modified ?modified ;
                 up:version  ?version ;
                 up:reviewed ?reviewed .

        OPTIONAL {
          BIND ( str('Reviewed') as ?status ) .
          FILTER (?reviewed = true)
        }

        OPTIONAL {
          BIND ( str('Uneviewed') as ?status ) .
          FILTER (?reviewed = false)
        }

        OPTIONAL {
          ?protein up:sequence ?sequence .
          ?sequence up:modified ?sequence_modified ;
                    up:version ?sequence_version .
        }
      }
    SPARQL
  end
end
