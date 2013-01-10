module RDFStoreClient
  def query(endpoint, sparql)
    client  = SPARQL::Client.new(endpoint)
    solutions = client.query(sparql)
    solutions.map {|solution| Hashr.new(solution.to_hash) }
  end
end

