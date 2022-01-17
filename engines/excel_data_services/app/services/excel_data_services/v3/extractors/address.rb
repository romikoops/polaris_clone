# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Extractors
      class Address < ExcelDataServices::V3::Extractors::Base
        def frame_data
          frame[%w[latitude longitude country_id]].to_a.uniq.map do |row|
            row.merge(
              "address_id" => Legacy::Address.create(
                latitude: row["latitude"],
                longitude: row["longitude"],
                country_id: row["country_id"]
              ).id
            )
          end
        end

        def join_arguments
          {
            "latitude" => "latitude",
            "longitude" => "longitude",
            "country_id" => "country_id"
          }
        end

        def frame_types
          {
            "latitude" => :object,
            "longitude" => :object,
            "country_id" => :object
          }
        end
      end
    end
  end
end
