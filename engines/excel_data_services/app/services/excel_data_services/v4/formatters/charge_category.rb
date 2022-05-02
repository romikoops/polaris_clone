# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class ChargeCategory < ExcelDataServices::V4::Formatters::Base
        ATTRIBUTE_KEYS = %w[fee_code fee_name organization_id].freeze

        def insertable_data
          sliced_frame = rows_for_insertion[ATTRIBUTE_KEYS]
          sliced_frame["code"] = sliced_frame.delete("fee_code")
          sliced_frame["name"] = sliced_frame.delete("fee_name")
          sliced_frame.to_a.uniq
        end

        def target_attribute
          "charge_category_id"
        end
      end
    end
  end
end
