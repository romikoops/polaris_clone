# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Parsers
        class ConnectedActions < ExcelDataServices::V3::Files::Parsers::Base
          attr_reader :scope

          SPLIT_PATTERN = /^(add_validator)|(add_formatter)|(add_extractor)|(model_importer)|(conflict)|(target_model)/.freeze
          delegate :organization, to: :state
          delegate :scope, to: :organization

          def model
            @model ||= nil
          end

          def actions
            (validators + conflicts + extractors + formatters + [importer])
          end

          private

          def validators
            @validators ||= []
          end

          def formatters
            @formatters ||= []
          end

          def extractors
            @extractors ||= []
          end

          def importer
            @importer ||= nil
          end

          def conflicts
            @conflicts ||= []
          end

          def add_validator(class_name)
            validators << "ExcelDataServices::V3::Validators::#{class_name}".constantize
          end

          def add_formatter(class_name)
            formatters << "ExcelDataServices::V3::Formatters::#{class_name}".constantize
          end

          def add_extractor(class_name)
            extractors << "ExcelDataServices::V3::Extractors::#{class_name}".constantize
          end

          def model_importer(model, options = {})
            @importer = ExcelDataServices::V3::Files::Importer.new(model: model, options: options)
          end

          def target_model(model)
            @model = model
          end

          def conflict(model, keys)
            conflicts << ExcelDataServices::V3::Files::Conflict.new(model: model, keys: keys)
          end
        end
      end
    end
  end
end
