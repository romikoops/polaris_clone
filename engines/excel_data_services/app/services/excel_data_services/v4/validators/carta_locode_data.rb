# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class CartaLocodeData < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::CartaLocodeData.new(state: state, target_frame: target_frame).perform
        end

        def error_reason(row:)
          "The locode '#{row['locode']}' cannot be found in our routing. Please consult the official UN/LOCODE list (https://locode.info)"
        end

        def required_key
          "locode_found"
        end

        def key_base
          "locode"
        end
      end
    end
  end
end
