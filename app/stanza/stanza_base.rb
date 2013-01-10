class StanzaBase
  include RDFStoreClient

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def render
    FS.evaluate(template, _context)
  end

  def context
    raise NotImplementedError
  end

  def template
    raise NotImplementedError
  end

  private

  def _context
    args = method(:context).parameters.reject {|type, _|
      type == :block
    }.map {|_, key|
      params[key]
    }

    send :context, *args
  end
end
