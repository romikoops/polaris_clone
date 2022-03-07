# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      class SheetValidator
        attr_reader :state, :sheet_parser

        def initialize(state:, sheet_parser:)
          @state = state
          @sheet_parser = sheet_parser
        end

        def valid?
          all_sheets_meet_requirements? && required_columns_present?
        end

        def required_columns_present?
          columns.select(&:required).all?(&:present_on_sheet?)
        end

        def all_sheets_meet_requirements?
          requirements.all?(&:valid?)
        end

        delegate :columns, :requirements, to: :sheet_parser
      end
    end
  end
end
