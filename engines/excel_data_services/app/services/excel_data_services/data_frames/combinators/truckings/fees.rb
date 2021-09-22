# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Combinators
      module Truckings
        class Fees < ExcelDataServices::DataFrames::Combinators::Base
          def frame
            return fee_metadata_frame.left_join(zone_frame, on: { "organization_id" => "organization_id" }) if fees_frame.empty?

            serviced
          end

          private

          def errors
            fee_metadata_states.flat_map(&:errors) +
              zone_states.flat_map(&:errors) +
              fees_state.errors
          end

          def zoned
            @zoned ||= if zoneless_fees.empty?
              zoned_fees
            else
              zoneless_fees
                .left_join(zone_frame, on: { "organization_id" => "organization_id" })
                .left_join(zoned_fees, on: { "zone" => "zone" })
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
            if serviceless_fees.empty?
              serviced_fees
            else
              serviceless_fees
                .left_join(carrier_and_service_frame, on: { "organization_id" => "organization_id" })
                .left_join(serviced_fees, on: { "service" => "service", "carrier" => "carrier", "carriage" => "carriage" })
            end
          end

          def zoneless_fees
            @zoneless_fees ||= fees_frame[fees_frame["zone"].missing]
          end

          def zoned_fees
            @zoned_fees ||= fees_frame[!fees_frame["zone"].missing]
          end

          def serviced_fees
            @serviced_fees ||= cargo_classed[(!cargo_classed["service"].missing) & (!cargo_classed["carrier"].missing)]
              .left_join(carrier_and_service_frame, on: { "service" => "service", "carrier" => "carrier", "carriage" => "carriage" })
          end

          def serviceless_fees
            @serviceless_fees ||= cargo_classed[(cargo_classed["service"].missing) & (cargo_classed["carrier"].missing)]
          end

          def cargo_classed_fees
            @cargo_classed_fees ||= zoned[!zoned["cargo_class"].missing]
          end

          def cargo_classless_fees
            @cargo_classless_fees ||= zoned[zoned["cargo_class"].missing]
          end

          def fee_metadata_frame
            @fee_metadata_frame ||= fee_metadata_states.inject(Rover::DataFrame.new) do |memo, fee_metadata_state|
              memo.concat(fee_metadata_state.frame)
            end
          end

          def fee_metadata_states
            @fee_metadata_states ||= file.rate_schemas.map do |schema|
              ExcelDataServices::DataFrames::Processors::Trucking::FeeMetadata.state(state: schema_state(schema: schema))
            end
          end

          def fees_state
            @fees_state ||= ExcelDataServices::DataFrames::Processors::Trucking::Fees.state(state: schema_state(schema: file.fee_schema))
          end

          def zone_states
            @zone_states ||= file.rate_schemas.map do |schema|
              ExcelDataServices::DataFrames::Processors::Trucking::ZoneRow.state(state: schema_state(schema: schema))
            end
          end

          def fees_frame
            @fees_frame ||= fees_state.frame
          end

          def zone_frame
            @zone_frame ||= zone_states.inject(Rover::DataFrame.new) do |memo, zone_state|
              memo.concat(zone_state.frame[%w[zone organization_id]])
            end
          end

          def cargo_class_frame
            @cargo_class_frame ||= Rover::DataFrame.new(
              fee_metadata_frame[%w[cargo_class organization_id]].to_a.uniq
            )
          end

          def carrier_and_service_frame
            @carrier_and_service_frame ||= Rover::DataFrame.new(
              fee_metadata_frame[%w[service carrier organization_id tenant_vehicle_id carriage]].to_a.uniq
            )
          end
        end
      end
    end
  end
end
