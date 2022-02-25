# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Operations
      class TruckingFees < ExcelDataServices::V3::Operations::Base
        STATE_COLUMNS = %w[hub_id group_id organization_id row sheet_name].freeze
        METADATA_COLUMNS = %w[
          cbm_ratio
          truck_type
          load_type
          cargo_class
          direction
          carrier
          carrier_code
          service
          effective_date
          expiration_date
          organization_id
        ].freeze

        def perform
          return state if fees_frame.empty?

          super
        end

        private

        def operation_result
          @operation_result ||= non_fees_frame.concat(fees_with_metadata)
        end

        def fees_with_metadata
          @fees_with_metadata ||= metadata_frame.inner_join(
            serviced,
            on: {
              "service" => "service",
              "carrier" => "carrier",
              "direction" => "direction",
              "cargo_class" => "cargo_class",
              "truck_type" => "truck_type"
            }
          ).left_join(zone_and_country_frame, on: { "zone" => "zone" })
        end

        def zoned
          @zoned ||= if zoneless_fees.empty?
            zoned_fees
          else
            zoneless_fees.left_join(zone_frame, on: { "cargo_class" => "cargo_class" }).concat(zoned_fees)
          end
        end

        def cargo_classed
          @cargo_classed ||= if cargo_classless_fees.empty?
            cargo_classed_fees
          else
            cargo_classless_fees
              .left_join(cargo_class_frame, on: { "organization_id" => "organization_id" })
              .left_join(cargo_classed_fees, on: { "cargo_class" => "cargo_class" })
            end
        end

        def serviced
          @serviced ||= if serviceless_fees.empty?
            serviced_fees
          else
            serviceless_fees
              .left_join(carrier_and_service_frame, on: { "organization_id" => "organization_id" })
              .concat(serviced_fees)
          end
        end

        def zoneless_fees
          @zoneless_fees ||= cargo_classed[cargo_classed["zone"].missing]
        end

        def zoned_fees
          @zoned_fees ||= cargo_classed[!cargo_classed["zone"].missing].left_join(zone_frame, on: { "zone" => "zone" })
        end

        def serviced_fees
          @serviced_fees ||= zoned[(!zoned["service"].missing) & (!zoned["carrier"].missing)]
            .left_join(carrier_and_service_frame, on: { "service" => "service", "carrier" => "carrier", "direction" => "direction" })
        end

        def serviceless_fees
          @serviceless_fees ||= zoned[(zoned["service"].missing) & (zoned["carrier"].missing)]
        end

        def cargo_classed_fees
          @cargo_classed_fees ||= fees_frame[!fees_frame["cargo_class"].missing]
        end

        def cargo_classless_fees
          @cargo_classless_fees ||= fees_frame[fees_frame["cargo_class"].missing]
        end

        def fees_frame
          @fees_frame ||= frame[frame["rate_type"] == "trucking_fee"]
        end

        def non_fees_frame
          @non_fees_frame ||= frame[frame["rate_type"] == "trucking_rate"]
        end

        def zone_frame
          @zone_frame ||= Rover::DataFrame.new(non_fees_frame[[identifier, "zone", "cargo_class"]].to_a.uniq)
        end

        def zone_and_country_frame
          @zone_and_country_frame ||= Rover::DataFrame.new(frame[!frame["country_code"].missing][%w[zone country_code]].to_a.uniq)
        end

        def cargo_class_frame
          @cargo_class_frame ||= Rover::DataFrame.new(non_fees_frame[%w[cargo_class organization_id]].to_a.uniq)
        end

        def carrier_and_service_frame
          @carrier_and_service_frame ||= Rover::DataFrame.new(
            metadata_frame[%w[service carrier carrier_code direction organization_id]].to_a.uniq
          )
        end

        def metadata_frame
          @metadata_frame ||= Rover::DataFrame.new(non_fees_frame[METADATA_COLUMNS].to_a.uniq)
        end

        def identifier
          @identifier ||= frame["identifier"].to_a.first
        end
      end
    end
  end
end
