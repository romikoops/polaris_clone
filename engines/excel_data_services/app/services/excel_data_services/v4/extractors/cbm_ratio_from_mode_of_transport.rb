# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class CbmRatioFromModeOfTransport < ExcelDataServices::V4::Extractors::Base
        def frame_data
          Pricings::Pricing::WM_RATIO_LOOKUP.map do |key, ratio|
            { "mode_of_transport" => key.to_s, "join_value" => nil, "cbm_ratio" => ratio }
          end
        end

        def join_arguments
          { "cbm_ratio" => "join_value", "mode_of_transport" => "mode_of_transport" }
        end

        def frame_types
          { "cbm_ratio" => :object, "mode_of_transport" => :object }
        end
      end
    end
  end
end
