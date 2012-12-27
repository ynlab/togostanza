class StanzaBase
  include RDFStoreClient

  def render(gene_id)
    ctx = context(gene_id)
    FS.evaluate(self.class::TEMPLATE, ctx)
  end

  def context(gene_id)
    raise NotImplementedError
  end
end
