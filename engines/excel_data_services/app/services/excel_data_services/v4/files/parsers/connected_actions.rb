# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class ConnectedActions
          attr_reader :scope, :state

          KEYS = %i[validators conflicts extractors formatters importers].freeze

          delegate :organization, to: :state
          delegate :scope, to: :organization

          def initialize(state:, schema_data:)
            @state = state
            @schema_data = schema_data
          end

          def actions
            (validators + conflicts + extractors + [formatter] + [importer])
          end

          private

          attr_reader :schema_data

          def validators
            @validators ||= (schema_data[:validators] || []).map do |validator|
              "ExcelDataServices::V4::Validators::#{validator}".constantize
            end
          end

          def formatter
            @formatter ||= "ExcelDataServices::V4::Formatters::#{schema_data[:formatter]}".constantize
          end

          def extractors
            @extractors ||= (schema_data[:extractors] || []).map do |extractor|
              "ExcelDataServices::V4::Extractors::#{extractor}".constantize
            end
          end

          def importer
            @importer ||= ExcelDataServices::V4::Files::Importer.new(model: importer_data[:model].constantize, options: importer_data[:options] || {}) if importer_data.present?
          end

          def conflicts
            @conflicts ||= (schema_data[:conflicts] || []).map do |conflict|
              ExcelDataServices::V4::Files::Conflict.new(model: conflict[:model].constantize, keys: conflict[:conflict_keys])
            end
          end

          def importer_data
            schema_data[:importer]
          end
        end
      end
    end
  end
end
