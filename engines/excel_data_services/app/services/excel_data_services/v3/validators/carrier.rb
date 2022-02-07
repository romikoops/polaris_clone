# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class Carrier < ExcelDataServices::V3::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V3::Extractors::Carrier.state(state: state)
        end

        def key_base
          "carrier"
        end
      end
    end
  end
end
