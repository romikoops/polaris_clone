# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Files
      class Base
        def initialize(file:)
          @file = file
        end

        private

        attr_reader :file

        def single_sheet(sheet_class:)
          return if sheet_class.blank?

          file.sheets.map { |sheet_name| sheet_class.new(file: file, sheet_name: sheet_name) }.find(&:valid?)
        end

        def multiple_sheets(sheet_class:)
          return [] if sheet_class.blank?

          file.sheets.map { |sheet_name| sheet_class.new(file: file, sheet_name: sheet_name) }.select(&:valid?)
        end
      end
    end
  end
end
