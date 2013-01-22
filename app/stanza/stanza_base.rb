require 'togo_stanza/sparql_client'

class StanzaBase
  class_attribute :properties

  class << self
    def find_by_slug(slug)
      "#{slug.camelize}Stanza".constantize
    end

    def property(name, val = nil, &block)
      raise ArgumentError, 'You must specify exactly one of either a value or block' unless [val, block].one?(&:nil?)

      self.properties ||= {}
      self.properties[name] = block || val
    end

    def slug
      name.underscore.sub(/_stanza$/, '')
    end

    def root
      Rails.root.join('app', 'stanza', slug)
    end
  end

  delegate :slug, :root, to: 'self.class'

  attr_reader :params

  def initialize(params = {})
    @params = params
  end

  def render
    Tilt.new(template_path).render(Hashie::Mash.new(context))
  end

  def template_path
    root.join('template.hbs').to_s
  end

  def context
    Parallel.map(properties, in_threads: 16) {|name, val|
      [name, fetch_property(val)]
    }.each_with_object({}) {|(name, val), hash|
      hash[name] = val
    }
  end

  def query(endpoint, sparql)
    TogoStanza::SPARQLClient.new(endpoint).query(sparql)
  end

  private

  def fetch_property(val)
    return val unless val.respond_to?(:call)

    args = val.parameters.reject {|type, _|
      type == :block
    }.map {|_, key|
      params[key]
    }

    instance_exec(*args, &val)
  end
end
