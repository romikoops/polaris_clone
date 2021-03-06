# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Augmenters
      module Trucking
        class Metadata < ExcelDataServices::DataFrames::Augmenters::Base
          def perform
            super
            return state if frame.empty?

            state.frame = correct_frame
            correct_service_and_carrier_keys
            find_or_create_service_level
            state
          end

          def correct_frame
            frame.delete("city")
            frame.inner_join(carriage_frame, on: { "direction" => "direction" })
          end

          def augments
            %w[hub_id group_id organization_id]
          end
        end
      end
    end
  end
end
