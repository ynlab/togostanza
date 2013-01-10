class StanzaBase
  include RDFStoreClient

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def render
    Tilt.new(template_path).render(_context)
  end

  def template_path
    Rails.root.join('app', 'stanza', 'templates', "#{self.class.name.underscore}.hbs").to_s
  end

  def context
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
