# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Framers
      class SacoImport < ExcelDataServices::V4::Framers::Base
        private

        def framed_data
          data_with_overrides[final_table_keys - %w[origin_hub period]]
        end

        def data_with_overrides
          @data_with_overrides ||= data
            .inner_join(overrides, on: { "sheet_name" => "sheet_name" })
            .left_join(period_frame, on: { "effective_date" => "expansion_value", "expiration_date" => "expansion_value" })
        end

        def final_table_keys
          headers | overrides.keys | %w[row organization_id target_frame]
        end

        def data
          @data ||= sheet_names.inject(Rover::DataFrame.new) do |result_frame, sheet_name|
            result_frame.concat(ExcelDataServices::V4::Framers::SheetFramer.new(sheet_name: sheet_name, frame: table_values).perform)
          end
        end

        def table_values
          @table_values ||= frame[frame["row"] >= 6]
        end

        def period_values
          @period_values ||= frame.filter("header" => "period").to_a.first
        end

        def period_frame
          @period_frame ||= Rover::DataFrame.new(period_frame_data)
        end

        def period_frame_data
          effective_date, expiration_date = period_values["value"].split(" - ").map(&:to_date)
          [{ "effective_date" => effective_date, "expiration_date" => expiration_date, "expansion_value" => nil }]
        end
      end
    end
  end
end
