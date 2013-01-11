module RDFStoreClient
  MAPPINGS = {
    refseq:  'http://lod.dbcls.jp/openrdf-sesame/repositories/togogenome'
  }

  def query(endpoint, sparql)
    endpoint = MAPPINGS[endpoint] || endpoint
    client   = SPARQL::Client.new(endpoint)

    client.query(sparql).map {|binding|
      binding.each_with_object({}) {|(name, term), hash|
        hash[name] = term.to_s
      }
    }
  end
end
