# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      class SheetParser
        SPLIT_PATTERN = /^(pipeline)/.freeze

        attr_reader :section, :state, :pipelines

        delegate :xlsx, :organization, to: :state
        delegate :sheets, to: :xlsx

        def initialize(section:, state:)
          @section = section
          @state = state
          @pipelines = []
          ExcelDataServices::V4::Files::Parsers::Schema.new(path: "file_data", section: section, pattern: SPLIT_PATTERN).perform do |schema_lines|
            instance_eval(schema_lines)
          end
        end

        def pipeline(section)
          @pipelines << section
        end
      end
    end
  end
end
