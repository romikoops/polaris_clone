# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class TypeAvailability < ExcelDataServices::V4::Formatters::Base
        ATTRIBUTE_KEYS = %w[
          carriage
          load_type
          truck_type
          country_id
          query_method
        ].freeze

        def insertable_data
          combined_frame[ATTRIBUTE_KEYS].to_a.uniq
        end

        def combined_frame
          @combined_frame ||= metadata_frame.left_join(country_and_query_method, on: { "organization_id" => "organization_id" })
        end

        def metadata_frame
          @metadata_frame ||= state.frame("default")
        end

        def country_and_query_method
          @country_and_query_method ||= zone_frame[%w[country_id query_method organization_id]].uniq
        end

        def zone_frame
          @zone_frame ||= state.frame("zones")
        end
      end
    end
  end
end
