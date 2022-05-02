# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class HubAvailability < ExcelDataServices::V4::Formatters::Base
        ATTRIBUTE_KEYS = %w[
          hub_id
          type_availability_id
        ].freeze

        def insertable_data
          rows_for_insertion[ATTRIBUTE_KEYS].to_a.uniq
        end

        def target_attribute
          nil
        end
      end
    end
  end
end
