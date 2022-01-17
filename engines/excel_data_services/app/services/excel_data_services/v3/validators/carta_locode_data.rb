# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class CartaLocodeData < ExcelDataServices::V3::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V3::Extractors::CartaLocodeData.state(state: state)
        end

        def error_reason(row:)
          "The locode '#{row['locode']}' cannot be found in our routing. Please consult the official UN/LOCODE list (https://locode.info)"
        end

        def required_key
          "locode_found"
        end
      end
    end
  end
end
