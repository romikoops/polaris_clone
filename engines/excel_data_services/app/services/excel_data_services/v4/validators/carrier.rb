# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class Carrier < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::Carrier.new(state: state, target_frame: target_frame).perform
        end

        def key_base
          "carrier"
        end
      end
    end
  end
end
