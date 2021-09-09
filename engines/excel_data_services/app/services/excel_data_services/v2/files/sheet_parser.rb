# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Files
      class SheetParser
        # This class holds the abstracted logc for the parsing and execution of config files.
        SPLIT_PATTERN = /^(add_operation)|(add_extractor)|(add_formatter)|(model_importer)|(conflict)|(target_model)/.freeze
        attr_reader :section, :state, :type, :columns, :requirements, :prerequisites, :dynamic_columns,
          :importers, :row_validations, :pipelines

        delegate :xlsx, :organization, to: :state

        def initialize(section:, state:, type:)
          @section = section
          @state = state
          @type = type
          @columns = []
          @requirements = []
          @prerequisites = []
          @pipelines = []
          @dynamic_columns = []
          @row_validations = []
          parse_config
        end

        def parse_config
          type == "section" ? initialize_section : initialize_sheet_type
        end

        def initialize_section
          sorted_dependencies.each do |dependency_section|
            schema_file = File.read(File.expand_path("./section_data/#{dependency_section.underscore}", __dir__))
            relevant_lines = schema_file.lines.reject { |line| line.match?(SPLIT_PATTERN) }.join
            instance_eval(relevant_lines)
          end
        end

        def initialize_sheet_type
          schema_file = File.read(File.expand_path("./file_data/#{section.underscore}", __dir__))
          instance_eval(schema_file)
        end

        def column(header, options = {})
          existing_columns = @columns.select { |col| col.header == header }
          new_columns = xlsx.sheets.map { |sheet_name| ExcelDataServices::V2::Files::Tables::Column.new(xlsx: xlsx, sheet_name: sheet_name, header: header, options: options) }
          @columns = (@columns - existing_columns) + new_columns
        end

        def add_dynamic_columns(including: [], excluding: [])
          # Dynamic columns refer to any Column not listed in the config file. You can specify columns to take or to ignore. This class defines Columns on the fly to
          # ensure the values of each dynamic column are added to the data frame for each Sheet object

          @dynamic_columns << ExcelDataServices::V2::Files::Tables::DynamicColumns.new(including: including, excluding: excluding)
        end

        def required(rows, columns, content)
          @requirements |= xlsx.sheets.map do |sheet_name|
            ExcelDataServices::V2::Files::Requirement.new(rows: rows, columns: columns, content: content, sheet_name: sheet_name, xlsx: xlsx)
          end
        end

        def prerequisite(section)
          @prerequisites << section
        end

        def pipeline(section)
          @pipelines << section
        end

        def row_validation(keys, comparator)
          @row_validations << ExcelDataServices::V2::Files::RowValidation.new(keys: keys, comparator: comparator)
        end

        def sorted_dependencies
          PrerequisiteExtractor.new(parent: section).dependencies
        end

        def dependency_actions
          @dependency_actions ||= sorted_dependencies.reverse.map do |dependency_section|
            ConnectedActions.new(state: state, section: dependency_section)
          end
        end

        class ConnectedActions
          attr_reader :section, :state, :model, :operations, :importer, :conflicts, :extractors, :formatters

          delegate :xlsx, :organization, to: :state

          def initialize(section:, state:)
            @section = section
            @state = state
            @operations = []
            @extractors = []
            @formatters = []
            @dynamic_columns = []
            @importer = nil
            @conflicts = []
            @model = nil
            @required_sections ||= []
            populate_columns
          end

          def actions
            (operations + extractors + conflicts + formatters)
          end

          private

          def populate_columns
            schema_file = File.read(File.expand_path("./section_data/#{section.underscore}", __dir__))
            relevant_lines = schema_file.lines.select { |line| line.match?(SPLIT_PATTERN) }.join
            instance_eval(relevant_lines)
          end

          def add_operation(class_name)
            @operations << "ExcelDataServices::V2::Operations::#{class_name}".constantize
          end

          def add_extractor(class_name)
            @extractors << "ExcelDataServices::V2::Extractors::#{class_name}".constantize
          end

          def add_formatter(class_name)
            @formatters << "ExcelDataServices::V2::Formatters::#{class_name}".constantize
          end

          def model_importer(model, options = {})
            @importer = ExcelDataServices::V2::Files::Importer.new(model: model, options: options)
          end

          def target_model(model)
            @model = model
          end

          def conflict(model, keys)
            @conflicts << ExcelDataServices::V2::Files::Conflict.new(model: model, keys: keys)
          end
        end
      end
    end
  end
end
