# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Operations
      class TruckingFees < ExcelDataServices::V4::Operations::Base
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
          @operation_result ||= metadata_frame.inner_join(
            serviced,
            on: {
              "service" => "service",
              "carrier" => "carrier",
              "direction" => "direction",
              "cargo_class" => "cargo_class",
              "truck_type" => "truck_type"
            }
          )
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

        def serviced_fees
          @serviced_fees ||= cargo_classed[(!cargo_classed["service"].missing) & (!cargo_classed["carrier"].missing)]
            .inner_join(carrier_and_service_frame, on: { "service" => "service", "carrier" => "carrier", "direction" => "direction" })
        end

        def serviceless_fees
          @serviceless_fees ||= cargo_classed[(cargo_classed["service"].missing) & (cargo_classed["carrier"].missing)]
        end

        def cargo_classed_fees
          @cargo_classed_fees ||= fees_frame[!fees_frame["cargo_class"].missing]
        end

        def cargo_classless_fees
          @cargo_classless_fees ||= fees_frame[fees_frame["cargo_class"].missing]
        end

        def fees_frame
          @fees_frame ||= state.frame("fees")
        end

        def non_fees_frame
          @non_fees_frame ||= state.frame("rates").left_join(metadata_frame, on: { "organization_id" => "organization_id", "sheet_name" => "sheet_name" })
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
          @metadata_frame ||= state.frame("default")
        end

        def identifier
          @identifier ||= frame["identifier"].to_a.first
        end
      end
    end
  end
end
