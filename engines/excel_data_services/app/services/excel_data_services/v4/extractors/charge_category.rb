# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class ChargeCategory < ExcelDataServices::V4::Extractors::Base
        # Fee names and codes are handled by ChargeCategories still. Using the fee_code andd fee_name attributes we can extract the charge_category_id and add it to the frame. As with all Extractors, those lines that are missing the required_key will have an error generated

        def frame_data
          Legacy::ChargeCategory.where(organization_id: organization_ids)
            .select("charge_categories.id as charge_category_id, code as fee_code, name as fee_name, organization_id")
        end

        def join_arguments
          {
            "fee_code" => "fee_code", "organization_id" => "organization_id"
          }
        end

        def frame_types
          {
            "charge_category_id" => :object,
            "fee_code" => :object,
            "fee_name" => :object
          }
        end
      end
    end
  end
end
