# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class PrimaryFeeCode < ExcelDataServices::V4::Extractors::Base
        PLACEHOLDER = ExcelDataServices::V4::Operations::Dynamic::DataColumn::PRIMARY_CODE_PLACEHOLDER

        def frame_data
          Organizations::Organization.where(id: organization_ids).flat_map do |org|
            primary_fee_code = state.organization.scope.primary_freight_code.downcase
            [
              { "fee_code" => primary_fee_code, "fee_name" => primary_fee_code.upcase, "join_value" => PLACEHOLDER, "organization_id" => org.id },
              { "fee_code" => "included_#{primary_fee_code}", "fee_name" => primary_fee_code.upcase, "join_value" => "included_", "organization_id" => org.id }
            ]
          end
        end

        def join_arguments
          { "fee_code" => "join_value", "organization_id" => "organization_id" }
        end

        def frame_types
          { "fee_code" => :object, "join_value" => :object }
        end
      end
    end
  end
end
