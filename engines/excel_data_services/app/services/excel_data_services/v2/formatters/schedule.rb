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
          frame["origin"] = frame.delete("origin_locode")
          frame["destination"] = frame.delete("destination_locode")
          frame[ATTRIBUTE_KEYS].to_a
        end
      end
    end
  end
  end
