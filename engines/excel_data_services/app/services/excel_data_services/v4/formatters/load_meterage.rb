# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class LoadMeterage
        VERSION_KEYS = %w[organization_id sheet_name].freeze

        def initialize(frame:)
          @frame = frame
        end

        def load_meterage
          frame.group_by(VERSION_KEYS).inject(Rover::DataFrame.new) do |result, group|
            result.concat(LoadMeterageFormat.new(row: group.first_row).perform)
          end
        end

        private

        attr_reader :frame

        class LoadMeterageFormat
          LOAD_METERAGE_KEYS = %w[
            load_meterage_ratio
            load_meterage_stackable_type
            load_meterage_non_stackable_type
            load_meterage_hard_limit
            load_meterage_stackable_limit
            load_meterage_non_stackable_limit
          ].freeze

          def initialize(row:)
            @row = row
          end

          def perform
            Rover::DataFrame.new([versioned_load_meterage_hash])
          end

          private

          attr_reader :row

          def versioned_load_meterage_hash
            row.slice("sheet_name", "organization_id").merge("load_meterage" => load_meterage_hash)
          end

          def load_meterage_hash
            row.slice(*LOAD_METERAGE_KEYS).transform_keys { |key| key.delete_prefix("load_meterage_") }
              .tap do |datum|
                datum["hard_limit"] = datum["hard_limit"].present?
                datum["stackable_type"] ||= legacy_load_meterage_limit_type
                datum["stackable_limit"] ||= row["load_meterage_#{legacy_load_meterage_limit_type}"]
              end
          end

          def legacy_load_meterage_limit_type
            @legacy_load_meterage_limit_type ||= %w[area height].find { |type| row["load_meterage_#{type}"].present? }
          end
        end
      end
    end
  end
end
