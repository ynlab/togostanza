require 'stanza/context'
require 'stanza/querying'
require 'stanza/markdown'

module Stanza
  class Base
    include Context
    include Querying

    class << self
      def id
        name.underscore.sub(/_stanza$/, '')
      end

      def root
        Rails.root.join('app', 'stanza', id)
      end

      def find(id)
        "#{id.camelize}Stanza".constantize
      end
    end

    delegate :id, :root, to: 'self.class'

    def initialize(params = {})
      @params = params
    end

    attr_reader :params

    def context
      super(params)
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
