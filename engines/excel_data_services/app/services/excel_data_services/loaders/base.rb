# frozen_string_literal: true

module ExcelDataServices
  module Loaders
    class Base
      def initialize(organization:)
        @organization = organization
      end

      def perform
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      private

      attr_reader :organization
    end
  end
end
