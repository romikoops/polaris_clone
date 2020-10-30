# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Augmenters
      module Trucking
        class Fees < ExcelDataServices::DataFrames::Augmenters::Base
          def perform
            super
            remove_sheet_name
            return state if frame.empty?

            state.frame = frame.inner_join(carriage_frame, on: {"direction" => "direction"})
            state
          end
        end
      end
    end
  end
end
