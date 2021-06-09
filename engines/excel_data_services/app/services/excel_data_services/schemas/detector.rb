# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    class Detector
      SCHEMAS = [
        ExcelDataServices::Schemas::Files::Trucking,
        ExcelDataServices::Schemas::Files::Hubs
      ].freeze

      attr_reader :xlsx

      def self.detect(xlsx:)
        new(xlsx: xlsx).perform
      end

      def initialize(xlsx:)
        @xlsx = xlsx
      end

      def perform
        SCHEMAS.each do |schema|
          schema_file = schema.new(file: xlsx)
          return schema_file if schema_file.valid?
        end
        false
      end
    end
  end
end
