# frozen_string_literal: true

module ChargeCalculator
  module Contexts
    class Base
      extend Forwardable
      def_delegator :hash, :fetch

      def to_h
        hash
      end

      def hash
        raise NotImplementedError
      end

      def [](key)
        hash[key].is_a?(Proc) ? hash[key].call(self) : hash[key]
      end
    end
  end
end
