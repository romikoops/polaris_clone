# frozen_string_literal: true

module ChargeCalculator
  module Fields
    class Base
      def value
        raise NotImplementedError
      end

      private
    end
  end
end
