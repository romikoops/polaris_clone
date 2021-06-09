# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Augmenters
      module Hubs
        class Hubs < ExcelDataServices::DataFrames::Augmenters::Base
          def perform
            super
            remove_sheet_name
            return state if frame.empty?

            state.frame = frame.inner_join(address_frame, on: join_arguments)
            state
          end

          def address_frame
            Rover::DataFrame.new(frame_data, types: frame_types)
          end

          def frame_data
            frame[%w[latitude longitude full_address country]].to_a.map do |address_row|
              new_address = Legacy::Address.new(
                latitude: address_row["latitude"],
                longitude: address_row["longitude"],
                geocoded_address: address_row["full_address"]
              )
              new_address.reverse_geocode
              new_address.save!
              address_row.slice("latitude", "longitude").merge("address_id" => new_address.id)
            end
          end

          def join_arguments
            { "latitude" => "latitude", "longitude" => "longitude" }
          end

          def frame_types
            { "address_id" => :object, "latitude" => :object, "longitude" => :object }.merge(
              ExcelDataServices::DataFrames::DataProviders::Hubs::Hubs.column_types
            )
          end
        end
      end
    end
  end
end
