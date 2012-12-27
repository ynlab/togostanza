class StanzaBase
  def render(gene_id)
    solutions = context(gene_id)
    FS.evaluate(self.class::TEMPLATE, Struct({context: solutions.map {|solution| solution.to_hash }}))
  end

  def context(gene_id)
    raise 'Called abstract method ...'
  end

  private

  def Struct(args)
    case args
    when Hash
      Struct.new(*args.keys).new(*args.values.map do |s|
        case s
        when Hash then Struct(s)
        when Array then s.map {|ss| Struct(ss)}
        else s
        end
      end
     )
    end
  end
end
