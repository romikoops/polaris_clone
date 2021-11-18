# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class PrimaryFeeCode < ExcelDataServices::V2::Extractors::Base
        def frame_data
          [
            { "fee_code" => primary_fee_code, "fee_name" => primary_fee_code.upcase, "join_value" => nil },
            { "fee_code" => included_fee_code, "fee_name" => primary_fee_code.upcase, "join_value" => "included_" }
          ]
        end

        def join_arguments
          { "fee_code" => "join_value" }
        end

        def frame_types
          { "fee_code" => :object, "join_value" => :object }
        end

        def primary_fee_code
          @primary_fee_code ||= state.organization.scope.primary_freight_code.downcase
        end

        def included_fee_code
          "included_#{primary_fee_code}"
        end
      end
    end
  end
end
