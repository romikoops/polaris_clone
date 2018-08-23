# frozen_string_literal: true

module ChargeCalculator
  module Reducers
    class Base
      def apply
        raise NotImplementedError
      end
    end
  end
end
