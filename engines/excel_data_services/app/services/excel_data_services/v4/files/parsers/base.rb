# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Base
          attr_reader :state, :section

          def initialize(section:, state:)
            @section = section
            @state = state
          end

          delegate :xlsx, :xml, :organization, to: :state
          delegate :sheets, to: :xlsx
          delegate :scope, to: :organization

          private

          def schema_data
            @schema_data ||= ExcelDataServices::V4::Files::Parsers::Schema.new(
              section: section, keys: self.class::KEYS
            ).perform
          end

          def non_empty_sheets
            @non_empty_sheets ||= xlsx.sheets.select { |all_sheet_name| xlsx.sheet(all_sheet_name).first_column }
          end
        end
      end
    end
  end
end
