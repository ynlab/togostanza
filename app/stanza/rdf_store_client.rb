module RDFStoreClient
  MAPPINGS = {
    refseq:  'http://lod.dbcls.jp/openrdf-sesame/repositories/togogenome'
  }

  def query(endpoint, sparql)
    endpoint = MAPPINGS[endpoint] || endpoint
    client   = SPARQL::Client.new(endpoint)

    client.query(sparql).map {|solution|
      Hashr.new(solution.to_hash)
    }
  end
end

