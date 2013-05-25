class ProteinEntryInformationStanza < Stanza::Base
  property :information do |tax_id, gene_id|
    informations = query(:uniprot, <<-SPARQL.strip_heredoc).first
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT ?protein ?entry_name ?created ?modified ?sequence_modified ?version ?sequence_version ?reviewed ?status
      WHERE {
        ?protein up:organism  taxonomy:#{tax_id} ;
                 rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .

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
