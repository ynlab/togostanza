class StanzaBase
  def render(gene_id)
    ctx = context(gene_id)
    FS.evaluate(self.class::TEMPLATE, Struct(ctx))
  end

  def context(gene_id)
    raise 'Called abstract method ...'
  end

  private

  def rdf2hash(results)
    results.map do |solution|
      results.variable_names.inject({}) do |memo, n|
        memo.merge case s = solution[n]
        when RDF::URI
          {n => {:type => "uri", :value => s.to_s }}
        when RDF::Node
          {n => {:type => "bnode", :value => s.id }}
        when RDF::Literal
          if s.datatype?
            {n => {:type => "literal", :datatype => s.datatype.to_s, :value => s.to_s }}
          elsif s.language
            {n => {:type => "literal", "xml:lang" => s.language.to_s, :value => s.to_s }}
          else
            {n => {:type => "literal", :value => s.to_s }}
          end
        end
      end
    end.first
  end

  def Struct(hash)
    Struct.new(*hash.keys).new(*hash.values.map {|s| Hash === s ? Struct(s) : s} )
  end
end
