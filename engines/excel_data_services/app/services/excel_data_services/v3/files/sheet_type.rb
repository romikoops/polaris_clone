# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      class SheetType
        # This class serves to provide a layer of abstraction across multiple Sections, while still operating mostly the same way. Sheet config files correspond to "types" of uploads eg. Trucking, Hubs
        attr_reader :file, :sheet_name, :columns, :requirements, :parser_class, :type, :arguments

        FailedTotalInsertion = Class.new(StandardError)

        def initialize(file:, type:, arguments:)
          @file = file
          @type = type
          @arguments = arguments
        end

        def perform
          pipelines.each do |pipeline|
            pipeline_state = pipeline.perform
            state.stats |= pipeline_state.stats
            next if pipeline_state.errors.blank?

            state.errors |= pipeline_state.errors
            break state
          end
          state
        end

        def state
          @state ||= ExcelDataServices::V3::State.new(
            file: file,
            section: type,
            overrides: Overrides.new(
              group_id: arguments[:group_id],
              hub_id: arguments[:hub_id]
            )
          )
        end

        def valid?
          xlsx_has_content? && pipelines.all?(&:valid?)
        end

        def pipelines
          @pipelines ||= sheet_parser.pipelines.map { |pipeline| ExcelDataServices::V3::Files::Section.new(state: duplicate_state_for_section(section: pipeline)) }
        end

        private

        def sheet_parser
          @sheet_parser ||= SheetParser.new(section: type, state: state)
        end

        def duplicate_state_for_section(section:)
          ExcelDataServices::V3::State.new(
            file: state.file,
            section: section,
            overrides: state.overrides
          )
        end

        def xlsx_has_content?
          state.xlsx.first_row.present?
        end
      end
    end
  end
end
