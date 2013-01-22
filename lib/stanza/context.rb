module Stanza
  module Context
    extend ActiveSupport::Concern

    included do
      class_attribute :properties
    end

    module ClassMethods
      def property(name, val = nil, &block)
        raise ArgumentError, 'You must specify exactly one of either a value or block' unless [val, block].one?(&:nil?)

        self.properties ||= {}
        self.properties[name] = block || val
      end
    end

    def context(params)
      ctx = Parallel.map(properties, in_threads: 16) {|name, val|
        [name, fetch_property(val, params)]
      }.each_with_object({}) {|(name, val), hash|
        hash[name] = val
      }

      Hashie::Mash.new(ctx)
    end

    private

    def fetch_property(val, params)
      return val unless val.respond_to?(:call)

      args = val.parameters.reject {|type, _|
        type == :block
      }.map {|_, key|
        params[key]
      }

      instance_exec(*args, &val)
    end
  end
end
