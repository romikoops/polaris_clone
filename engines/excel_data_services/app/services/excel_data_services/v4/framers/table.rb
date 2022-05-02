# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Framers
      class Table < ExcelDataServices::V4::Framers::Base
        private

        def framed_data
          data_with_overrides[final_table_keys]
        end

        def data_with_overrides
          @data_with_overrides ||= data.inner_join(overrides, on: { "sheet_name" => "sheet_name" })
        end

        def final_table_keys
          headers | overrides.keys | ["row"]
        end

        def data
          @data ||= sheet_names.inject(Rover::DataFrame.new) do |result_frame, sheet_name|
            result_frame.concat(ExcelDataServices::V4::Framers::SheetFramer.new(sheet_name: sheet_name, frame: values).perform)
          end
        end
      end
    end
  end
end
