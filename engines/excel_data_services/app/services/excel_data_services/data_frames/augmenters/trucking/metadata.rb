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
            state
          end

          def correct_frame
            frame["carrier"] = frame.delete("courier") if frame.include?("courier")
            frame["service"] = frame.delete("service_level") if frame.include?("service_level")
            frame.delete("city")
            frame.inner_join(carriage_frame, on: {"direction" => "direction"})
          end

          def augments
            %w[hub_id group_id organization_id]
          end
        end
      end
    end
  end
end
