# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class Base
      def result(*_args)
        raise NotImplementedError
      end
    end
  end
end
