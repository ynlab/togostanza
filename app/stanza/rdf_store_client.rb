module RDFStoreClient
  def sparql(endpoint, query)
    client  = SPARQL::Client.new(endpoint)
    solutions = client.query(query)
    solutions.map {|solution| Hashr.new(solution.to_hash) }
  end
end

