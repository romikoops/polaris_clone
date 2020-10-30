# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Augmenters
      class Base < ExcelDataServices::DataFrames::Base
        def perform
          augments.each do |key|
            value = state[key]
            frame[key] = value if value.present?
          end

          state
        end

        private

        def carriage_frame
          @carriage_frame ||= Rover::DataFrame.new(
            [{"carriage" => "pre", "direction" => "export"}, {"carriage" => "on", "direction" => "import"}]
          )
        end

        def remove_sheet_name
          frame.delete("sheet_name")
          frame
        end

        def augments
          []
        end
      end
    end
  end
end
