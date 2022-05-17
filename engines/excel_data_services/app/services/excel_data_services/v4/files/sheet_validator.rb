# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      class SheetValidator
        attr_reader :state, :section_parser

        def initialize(state:, section_parser:)
          @state = state
          @section_parser = section_parser
        end

        def valid?
          xlsx_has_content? && all_sheets_meet_requirements? && required_columns_present?
        end

        def required_columns_present?
          columns.select(&:required).all?(&:present_on_sheet?)
        end

        def all_sheets_meet_requirements?
          requirements.present? && requirements.all?(&:valid?)
        end

        delegate :columns, :requirements, to: :section_parser

        def xlsx_has_content?
          state.xml? || state.xlsx.first_row.present?
        end
      end
    end
  end
end
