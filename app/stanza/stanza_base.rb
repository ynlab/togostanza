class StanzaBase
  include RDFStoreClient

  def render(query_params)
    ctx = context(query_params)
    FS.evaluate(template, ctx)
  end

  def context(query_params)
    raise NotImplementedError
  end

  def template
    raise NotImplementedError
  end
end
