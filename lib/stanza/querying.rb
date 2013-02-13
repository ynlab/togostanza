module Stanza
  module Querying
    MAPPINGS = {
      togogenome: 'http://lod.dbcls.jp/openrdf-sesame5l/repositories/togogenome',
      uniprot:    'http://lod.dbcls.jp/openrdf-sesame5l/repositories/cyano',
      go:         'http://lod.dbcls.jp/openrdf-sesame5l/repositories/go'
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
  end
end
