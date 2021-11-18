# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Formatters
      class Schedule < ExcelDataServices::V2::Formatters::Base
        ATTRIBUTE_KEYS = %w[
          vessel_name
          origin
          destination
          origin_departure
          destination_arrival
          closing_date
          carrier
          service
          mode_of_transport
          vessel_code
          voyage_code
          organization_id
        ].freeze

        def insertable_data
          rows_for_insertion["origin"] = rows_for_insertion.delete("origin_locode")
          rows_for_insertion["destination"] = rows_for_insertion.delete("destination_locode")
          rows_for_insertion[ATTRIBUTE_KEYS].to_a
        end

        def target_attribute
          nil
        end
      end
    end
  end
end
