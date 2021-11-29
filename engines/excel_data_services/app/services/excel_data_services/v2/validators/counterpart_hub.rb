# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class CounterpartHub < ExcelDataServices::V2::Validators::Hub
        def extracted
          @extracted ||= ExcelDataServices::V2::Extractors::CounterpartHub.state(state: state)
        end

        def prefix
          "counterpart"
        end

        def append_errors_to_state
          frame_to_validate[frame_to_validate[required_key].missing].to_a.each do |error_row|
            append_error(row: error_row)
          end
        end

        def frame_to_validate
          frame[(!frame["counterpart_hub"].missing) | (!frame["counterpart_locode"].missing)]
        end
      end
    end
  end
end
