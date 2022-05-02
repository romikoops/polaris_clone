# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      class ConnectedActions
        attr_reader :section, :state, :model, :importer, :conflicts, :validators, :formatters, :extractors, :scope

        SPLIT_PATTERN = /^(add_validator)|(add_formatter)|(add_extractor)|(model_importer)|(conflict)|(target_model)/.freeze
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
          (validators + conflicts + extractors + formatters + [importer])
        end

        private

        def populate_columns
          ExcelDataServices::V4::Files::Parsers::Schema.new(path: "section_data", section: section.underscore, pattern: SPLIT_PATTERN).perform do |schema_lines|
            instance_eval(schema_lines)
          end
        end

        def add_validator(class_name)
          @validators << "ExcelDataServices::V4::Validators::#{class_name}".constantize
        end

        def add_formatter(class_name)
          @formatters << "ExcelDataServices::V4::Formatters::#{class_name}".constantize
        end

        def add_extractor(class_name)
          @extractors << "ExcelDataServices::V4::Extractors::#{class_name}".constantize
        end

        def model_importer(model, options = {})
          @importer = ExcelDataServices::V4::Files::Importer.new(model: model, options: options)
        end

        def target_model(model)
          @model = model
        end

        def conflict(model, keys)
          @conflicts << ExcelDataServices::V4::Files::Conflict.new(model: model, keys: keys)
        end
      end
    end
  end
end
