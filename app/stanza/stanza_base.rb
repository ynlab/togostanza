require 'togo_stanza/sparql_client'

class StanzaBase
  class_attribute :variables

  class << self
    def detect(name)
      "#{name.camelize}Stanza".constantize
    end

    def variable(name, &block)
      self.variables ||= {}
      self.variables[name] = block
    end
  end

  attr_reader :params

  def initialize(params = {})
    @params = params
  end

  def render
    Tilt.new(template_path).render(Hashie::Mash.new(context))
  end

  def template_path
    Rails.root.join('app', 'stanza', 'templates', "#{self.class.name.underscore}.hbs").to_s
  end

  def context
    variables.each_with_object({}) {|(name, block), hash|
      hash[name] = fetch_variable(block)
    }
  end

  def query(endpoint, sparql)
    TogoStanza::SPARQLClient.new(endpoint).query(sparql)
  end

  private

  def fetch_variable(block)
    args = block.parameters.reject {|type, _|
      type == :block
    }.map {|_, key|
      params[key]
    }

    instance_exec(*args, &block)
  end
end
