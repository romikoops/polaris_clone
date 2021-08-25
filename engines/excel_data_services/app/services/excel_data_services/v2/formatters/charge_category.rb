# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Formatters
      class ChargeCategory < ExcelDataServices::V2::Formatters::Base
        ATTRIBUTE_KEYS = %w[fee_code fee_name organization_id].freeze

        def insertable_data
          sliced_frame = frame[ATTRIBUTE_KEYS]
          sliced_frame["code"] = sliced_frame.delete("fee_code")
          sliced_frame["name"] = sliced_frame.delete("fee_name")
          sliced_frame.to_a.uniq
        end
      end
    end
  end
end
