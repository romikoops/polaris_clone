# frozen_string_literal: true

module Wheelhouse
  module Validations
    class Error < StandardError
      attr_reader :id, :section, :limit, :attribute, :message, :code

      def initialize(id:, section:, attribute:, message:, code:, limit: nil)
        @id = id
        @section = section
        @attribute = attribute
        @message = message
        @code = code
        @limit = limit
      end

      def matches?(cargo:, attr:, aggregate: false)
        aggregate_match = (aggregate && id == "aggregate")
        (aggregate_match || id == cargo.id) && attr == attribute
      end
    end
  end
end
