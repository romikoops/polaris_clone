# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      class SectionParser
        delegate :xlsx, :organization, to: :state

        attr_reader :state, :section

        def initialize(section:, state:)
          @section = section
          @state = state
        end

        def global_actions
          (operations + data_validations)
        end

        def column_parser
          @column_parser ||= ExcelDataServices::V4::Files::Parsers::Columns.new(section: section, state: state)
        end

        delegate :columns, :matrixes, :dynamic_columns, :sheets, to: :column_parser

        def data_validator_parser
          @data_validator_parser ||= ExcelDataServices::V4::Files::Parsers::DataValidators.new(section: section, state: state)
        end

        delegate :data_validations, to: :data_validator_parser

        def requirement_parser
          @requirement_parser ||= ExcelDataServices::V4::Files::Parsers::Requirements.new(section: section, state: state)
        end

        delegate :requirements, to: :requirement_parser

        def operation_parser
          @operation_parser ||= ExcelDataServices::V4::Files::Parsers::Operations.new(section: section, state: state)
        end

        delegate :operations, to: :operation_parser

        def ordered_connected_action_parser
          @ordered_connected_action_parser ||= ExcelDataServices::V4::Files::Parsers::OrderedConnectedActions.new(section: section, state: state)
        end

        delegate :connected_actions, to: :ordered_connected_action_parser

        def framer_parser
          @framer_parser ||= ExcelDataServices::V4::Files::Parsers::Framer.new(section: section, state: state)
        end

        delegate :framer, to: :framer_parser

        def xml_data_parser
          @xml_data_parser ||= ExcelDataServices::V4::Files::Parsers::Xml.new(section: section, state: state)
        end

        delegate :xml_columns, :xml_data, to: :xml_data_parser

        def headers
          xml_data_parser.headers + column_parser.headers
        end
      end
    end
  end
end
