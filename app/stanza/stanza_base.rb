class StanzaBase
  def render(gene_id)
    solutions = context(gene_id)
    FS.evaluate(self.class::TEMPLATE, Struct({context: solutions.map {|solution| solution.to_hash }}))
  end

  def context(gene_id)
    raise NotImplementedError
  end

  private

  def Struct(args)
    case args
    when Hash
      Struct.new(*args.keys).new(*args.values.map {|value|
        case value
        when Hash then Struct(value)
        when Array then value.map {|e| Struct(e) }
        else value
        end
      }
     )
    end
  end
end
