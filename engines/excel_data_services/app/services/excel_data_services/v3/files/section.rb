# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      class Section
        attr_reader :state

        delegate :section, to: :state

        def self.state(state:)
          new(state: state).perform
        end

        def initialize(state:)
          @state = state
        end

        def perform
          section_pipeline.each do |executor|
            @state = executor.perform
            return state if failed?
          end
          state
        end

        delegate :valid?, to: :sheet_validator

        private

        def section_pipeline
          [data_framer, pipeline_executor]
        end

        def sheet_validator
          @sheet_validator ||= ExcelDataServices::V3::Files::SheetValidator.new(state: state, section_parser: section_parser)
        end

        def pipeline_executor
          @pipeline_executor ||= ExcelDataServices::V3::Files::PipelineExecutor.new(state: state, section_parser: section_parser)
        end

        def data_framer
          @data_framer ||= ExcelDataServices::V3::Files::DataFramer.new(state: state, section_parser: section_parser)
        end

        def failed?
          state.errors.present?
        end

        def section_parser
          @section_parser ||= SectionParser.new(section: section, state: state)
        end
      end
    end
  end
end
