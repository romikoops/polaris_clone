# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class DestinationHub < ExcelDataServices::V3::Validators::Hub
        def extracted
          @extracted ||= ExcelDataServices::V3::Extractors::DestinationHub.state(state: state)
        end

        def prefix
          "destination"
        end

        def append_errors_to_state
          frame_to_validate[frame_to_validate[required_key].missing].to_a.each do |error_row|
            append_error(row: error_row)
          end
        end

        def frame_to_validate
          frame[(!frame["destination_hub"].missing) | (!frame["destination_locode"].missing)]
        end
      end
    end
  end
end
