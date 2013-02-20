require 'thor'
require 'launchy'
require 'uri'

module Stanza
  class CLI < Thor
    desc 'list', ''
    def list
      Stanza.all.map(&:id).sort.each do |id|
        say id
      end
    end

    desc 'show_context <stanza name> <param1=val1 param2=val2>', ''
    def show_context(id, *param_strs)
      params = convert_params(param_strs)

      puts JSON.pretty_generate(Stanza.find(id).new(params).context)
    end

    desc 'render <stanza name> <param1=val1 param2=val2>', ''
    def render(id, *param_strs)
      params = convert_params(param_strs)

      puts Stanza.find(id).new(params).render
    end

    desc 'open <stanza name> <param1=val1 param2=val2>', ''
    def open(id, *param_strs)
      query = convert_params(param_strs).to_query

      Launchy.open URI::HTTP.build(
        host:  'localhost',
        port:  3000,
        path:  "/stanza/#{id}",
        query: query
      )
    end

    private

    def convert_params(param_strs)
      param_strs.each_with_object({}) {|str, hash|
        k, v = str.split('=', 2)

        hash[k] = v.to_s
      }.with_indifferent_access
    end
  end
end
