# frozen_string_literal: true

module ChargeCalculator
  module Contexts
    class Base
      def to_h
        hash
      end

      def hash
        raise NotImplementedError
      end

      def [](key)
        call_if_proc(hash[key])
      end

      def fetch(key, default = nil, &block)
        call_if_proc(hash.fetch(key, default, &block))
      end

      private

      def call_if_proc(value)
        value.is_a?(Proc) ? value.call(self) : value
      end
    end
  end
end
