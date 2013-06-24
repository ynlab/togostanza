require 'stanza/expression_map'
require 'stanza/querying'
require 'stanza/markdown'

module Stanza
  class << self
    def find(id)
      "#{id.camelize}Stanza".constantize
    end

    def all
      Stanza::Base.descendants
    end

    def load_all!
      Dir[root.join('*_stanza.rb')].each do |f|
        require f
      end
    end

    def root
      Rails.root.join('app/stanza')
    end
  end

  class Base
    extend ExpressionMap::Macro
    include Querying

    define_expression_map :properties
    define_expression_map :resources

    property :css_uri do |css_uri|
      css_uri || '/stanza/assets/stanza.css'
    end

    class << self
      def id
        name.underscore.sub(/_stanza$/, '')
      end

      def root
        Stanza.root.join(id)
      end
    end

    delegate :id, :root, to: 'self.class'

    def initialize(params = {})
      @params = params
    end

    attr_reader :params

    def context
      Hashie::Mash.new(properties.resolve_all_in_parallel(self, params))
    end

    def resource(name)
      resources.resolve(self, name, params)
    end

    def render
      path = root.join('template.hbs')

      Tilt.new(path.to_s).render(context)
    end

    def help
      path = root.join('help.md')

      Markdown.render(path.read)
    end
  end
end
