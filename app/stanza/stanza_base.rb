class StanzaBase
  include RDFStoreClient

  def render(query_params)
    ctx = context(query_params)
    FS.evaluate(self.class::TEMPLATE, ctx)
  end

  def context(query_params)
    raise NotImplementedError
  end
end
