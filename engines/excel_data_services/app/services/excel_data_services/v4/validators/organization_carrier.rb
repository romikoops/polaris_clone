# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class OrganizationCarrier < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::OrganizationCarrier.new(state: state, target_frame: target_frame).perform
        end

        def key_base
          "carrier"
        end
      end
    end
  end
end
