# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      class DataFramer
        attr_reader :state, :section_parser

        def initialize(state:, section_parser:)
          @state = state
          @section_parser = section_parser
        end

        def perform
          @state.frame = framer_klass.perform
          @state.errors += framer_klass.errors
          state
        end

        private

        delegate :framer, to: :section_parser

        def framer_klass
          @framer_klass ||= framer.new(state: state, section_parser: section_parser)
        end
      end
    end
  end
end
