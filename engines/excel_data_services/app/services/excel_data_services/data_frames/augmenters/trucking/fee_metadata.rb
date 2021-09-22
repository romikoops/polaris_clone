# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Augmenters
      module Trucking
        class FeeMetadata < ExcelDataServices::DataFrames::Augmenters::Base
          def perform
            super
            return state if frame.empty?

            correct_service_and_carrier_keys
            find_or_create_service_level
            state.frame = frame.inner_join(carriage_frame, on: { "direction" => "direction" })
            state
          end
        end
      end
    end
  end
end
