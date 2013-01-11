class TogoStanza::SPARQLClient
  MAPPINGS = {
    refseq:  'http://lod.dbcls.jp/openrdf-sesame/repositories/togogenome'
  }

  def initialize(endpoint)
    @client = SPARQL::Client.new(MAPPINGS[endpoint] || endpoint)
  end

  def query(sparql)
    @client.query(sparql).map {|binding|
      binding.each_with_object({}) {|(name, term), hash|
        hash[name] = term.to_s
      }
    }
  end
end
