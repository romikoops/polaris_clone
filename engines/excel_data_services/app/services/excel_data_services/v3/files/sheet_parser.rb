# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      class SheetParser
        # This class holds the abstracted logic for the parsing and execution of config files.
        SPLIT_PATTERN = /^(add_validator)|(add_formatter)|(add_extractor)|(model_importer)|(conflict)|(target_model)/.freeze
        attr_reader :section, :state, :type, :columns, :requirements, :prerequisites, :dynamic_columns,
          :importers, :row_validations, :data_validations, :pipelines, :operations, :matrixes, :framer

        delegate :xlsx, :organization, to: :state

        def initialize(section:, state:, type:)
          @section = section
          @state = state
          @type = type
          @columns = []
          @matrixes = []
          @requirements = []
          @prerequisites = []
          @pipelines = []
          @operations = []
          @dynamic_columns = []
          @row_validations = []
          @data_validations = []
          @framer = ExcelDataServices::V3::Framers::Table
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
          @columns = expand_for_sheets(sheet_name: options[:sheet_name], exclude_sheets: options[:exclude_sheets]).inject(@columns) do |existing_columns, sheet_name|
            new_column = ExcelDataServices::V3::Files::Tables::Column.new(
              xlsx: xlsx,
              sheet_name: sheet_name,
              header: header,
              options: ExcelDataServices::V3::Files::Tables::Options.new(options: options)
            )
            merge_item_into_collection(collection: existing_columns, item: new_column)
          end
        end

        def matrix(header, options = {})
          @matrixes = expand_for_sheets(sheet_name: options[:sheet_name], exclude_sheets: options[:exclude_sheets]).inject(@matrixes) do |existing_matrixes, sheet_name|
            new_matrix = ExcelDataServices::V3::Files::Tables::Matrix.new(
              xlsx: xlsx,
              sheet_name: sheet_name,
              header: header,
              rows: options[:rows],
              columns: options[:columns],
              options: ExcelDataServices::V3::Files::Tables::Options.new(options: options)
            )
            merge_item_into_collection(collection: existing_matrixes, item: new_matrix)
          end
        end

        def merge_item_into_collection(collection:, item:)
          collection.reject { |col_item| col_item.header == item.header && col_item.sheet_name == item.sheet_name }.push(item)
        end

        def add_framer(klass)
          @framer = "ExcelDataServices::V3::Framers::#{klass}".constantize
        end

        def add_dynamic_columns(including: [], excluding: [])
          # Dynamic columns refer to any Column not listed in the config file. You can specify columns to take or to ignore. This class defines Columns on the fly to
          # ensure the values of each dynamic column are added to the data frame for each Sheet object

          @dynamic_columns << ExcelDataServices::V3::Files::Tables::DynamicColumns.new(including: including, excluding: excluding)
        end

        def required(rows, columns, content)
          @requirements = non_empty_sheets.map do |sheet_name|
            ExcelDataServices::V3::Files::Requirement.new(rows: rows, columns: columns, content: content, sheet_name: sheet_name, xlsx: xlsx)
          end
        end

        def prerequisite(section)
          @prerequisites << section
        end

        def pipeline(section)
          @pipelines << section
        end

        def add_operation(class_name)
          operation_class = "ExcelDataServices::V3::Operations::#{class_name}".constantize
          @operations << operation_class unless @operations.include?(operation_class)
        end

        def add_data_validator(class_name)
          data_validation_class = "ExcelDataServices::V3::Validators::#{class_name}".constantize
          @data_validations << data_validation_class unless @data_validations.include?(data_validation_class)
        end

        def row_validation(keys, comparator)
          @row_validations << ExcelDataServices::V3::Files::RowValidation.new(keys: keys, comparator: comparator)
        end

        def sorted_dependencies
          PrerequisiteExtractor.new(parent: section).dependencies
        end

        def dependency_actions
          @dependency_actions ||= sorted_dependencies.reverse.map do |dependency_section|
            ConnectedActions.new(state: state, section: dependency_section, scope: scope)
          end
        end

        def scope
          @scope ||= state.organization.scope
        end

        def expand_for_sheets(sheet_name:, exclude_sheets:)
          all_sheets = non_empty_sheets
          all_sheets = [sheet_name] & all_sheets if sheet_name.present?
          all_sheets -= exclude_sheets if exclude_sheets.present?
          all_sheets
        end

        def non_empty_sheets
          @non_empty_sheets ||= xlsx.sheets.select { |all_sheet_name| xlsx.sheet(all_sheet_name).first_column }
        end

        class ConnectedActions
          attr_reader :section, :state, :model, :importer, :conflicts, :validators, :formatters, :extractors, :scope

          delegate :xlsx, :organization, to: :state

          def initialize(section:, state:, scope:)
            @section = section
            @state = state
            @scope = scope
            @validators = []
            @formatters = []
            @extractors = []
            @dynamic_columns = []
            @importer = nil
            @conflicts = []
            @model = nil
            @required_sections ||= []
            populate_columns
          end

          def actions
            (validators + conflicts + extractors + formatters)
          end

          private

          def populate_columns
            schema_file = File.read(File.expand_path("./section_data/#{section.underscore}", __dir__))
            relevant_lines = schema_file.lines.select { |line| line.match?(SPLIT_PATTERN) }.join
            instance_eval(relevant_lines)
          end

          def add_validator(class_name)
            @validators << "ExcelDataServices::V3::Validators::#{class_name}".constantize
          end

          def add_formatter(class_name)
            @formatters << "ExcelDataServices::V3::Formatters::#{class_name}".constantize
          end

          def add_extractor(class_name)
            @extractors << "ExcelDataServices::V3::Extractors::#{class_name}".constantize
          end

          def model_importer(model, options = {})
            @importer = ExcelDataServices::V3::Files::Importer.new(model: model, options: options)
          end

          def target_model(model)
            @model = model
          end

          def conflict(model, keys)
            @conflicts << ExcelDataServices::V3::Files::Conflict.new(model: model, keys: keys)
          end
        end
      end
    end
  end
end
