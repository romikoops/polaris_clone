# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Formatters
      class TypeAvailability < ExcelDataServices::V3::Formatters::Base
        ATTRIBUTE_KEYS = %w[
          carriage
          load_type
          truck_type
          country_id
          query_method
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
