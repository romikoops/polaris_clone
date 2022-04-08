# frozen_string_literal: true

module Api
  module V2
    class ValidationErrorDecorator < Draper::Decorator
      delegate_all

      def attribute
        { payload_in_kg: "weight" }[super] || super.to_s
      end
    end
  end
end
