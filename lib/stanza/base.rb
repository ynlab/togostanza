require 'stanza/context'
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
    include Context
    include Querying

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

    property :css_uri do |css_uri|
      css_uri || '//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.2.2/css/bootstrap.min.css'
    end
  end
end
