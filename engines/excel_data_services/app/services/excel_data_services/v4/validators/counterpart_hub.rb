# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class CounterpartHub < ExcelDataServices::V4::Validators::Hub
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::CounterpartHub.new(state: state, target_frame: target_frame).perform
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
