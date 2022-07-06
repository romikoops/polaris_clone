# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class ChargeCategory < ExcelDataServices::V4::Formatters::Base
        ATTRIBUTE_KEYS = %w[fee_code fee_name organization_id].freeze

        def insertable_data
          charge_containing_frames.inject([]) do |result, inner_frame|
            sliced_frame = inner_frame[!inner_frame["fee_code"].missing][ATTRIBUTE_KEYS]
            sliced_frame["code"] = sliced_frame.delete("fee_code")
            sliced_frame["name"] = sliced_frame.delete("fee_name")
            (result + sliced_frame.to_a).uniq
          end
        end

        def target_attribute
          "charge_category_id"
        end

        def charge_containing_frames
          @charge_containing_frames ||= state.frames.values.select { |inner_frame| inner_frame.include?("fee_code") }
        end
      end
    end
  end
end
