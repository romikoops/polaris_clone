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
            @validators ||= (schema_data[:validators] || []).flat_map do |validator|
              target_frames_or_default(input: validator).map do |target_frame|
                ExcelDataServices::V4::Files::Parsers::ActionWrapper.new(
                  action: "ExcelDataServices::V4::Validators::#{validator[:type]}".constantize,
                  target_frame: target_frame
                )
              end
            end
          end

          def formatter
            @formatter ||= "ExcelDataServices::V4::Formatters::#{schema_data[:formatter]}".constantize
          end

          def extractors
            @extractors ||= (schema_data[:extractors] || []).flat_map do |extractor|
              target_frames_or_default(input: extractor).map do |target_frame|
                ExcelDataServices::V4::Files::Parsers::ActionWrapper.new(
                  action: "ExcelDataServices::V4::Extractors::#{extractor[:type]}".constantize,
                  target_frame: target_frame
                )
              end
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

          def target_frames_or_default(input:)
            input[:frames] || ["default"]
          end
        end
      end
    end
  end
end
