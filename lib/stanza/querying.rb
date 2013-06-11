module Stanza
  module Querying
    MAPPINGS = {
      togogenome: 'http://ep.dbcls.jp/sparql',
      uniprot:    'http://ep.dbcls.jp/sparql',
      go:         'http://ep.dbcls.jp/sparql'
    }

    def query(endpoint, sparql)
      client = SPARQL::Client.new(MAPPINGS[endpoint] || endpoint)

      Rails.logger.debug "SPARQL QUERY: \n#{sparql}"

      client.query(sparql).map {|binding|
        binding.each_with_object({}) {|(name, term), hash|
          hash[name] = term.to_s
        }
      }
    end

    def uniprot_url_from_togogenome(gene_id)
      # refseq の UniProt
      # slr1311 の時 "http://purl.uniprot.org/refseq/NP_439906.1"
      query(:togogenome, <<-SPARQL).first[:up]
      PREFIX insdc: <http://insdc.org/owl/>
      PREFIX idorg: <http://rdf.identifiers.org/database/>

      SELECT DISTINCT ?up
      WHERE {
        GRAPH <http://togogenome.org/refseq/> {
          ?s insdc:feature_locus_tag "slr1311" .
          ?s rdfs:seeAlso ?np .
          ?s rdfs:seeAlso ?xref .
          ?np rdf:type idorg:Protein .
          BIND (STRAFTER(STR(?np), "ncbiprotein/") AS ?npid)
          BIND (IRI(CONCAT("http://purl.uniprot.org/refseq/", ?npid)) AS ?up)
        }
      }
      SPARQL
    end
  end
end
