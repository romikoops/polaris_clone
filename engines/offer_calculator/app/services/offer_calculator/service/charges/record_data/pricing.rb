# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      module RecordData
        class Pricing
          MARGIN_TYPE = "freight_margin"
          attr_reader :record

          def initialize(record:)
            @record = record
          end

          def perform
            Rover::DataFrame.new(rate_frame_data)
          end

          private

          def rate_frame_data
            @rate_frame_data ||= pricing_fee_data.flat_map do |fee_row|
              PricingFeeRow.new(fee_row: fee_row.merge(base_row)).perform
            end
          end

          def pricing_fee_data
            @pricing_fee_data ||= fees.select("
              pricings_pricings.id as context_id,
              pricings_pricings.itinerary_id as itinerary_id,
              pricings_pricings.organization_id as organization_id,
              pricings_pricings.tenant_vehicle_id as tenant_vehicle_id,
              pricings_pricings.cargo_class as cargo_class,
              pricings_pricings.load_type as load_type,
              pricings_pricings.effective_date,
              pricings_pricings.expiration_date,
              itineraries.origin_hub_id as origin_hub_id,
              itineraries.destination_hub_id as destination_hub_id,
              itineraries.mode_of_transport as mode_of_transport,
              charge_categories.code as code,
              pricings_rate_bases.internal_code as rate_basis_name,
              pricings_fees.currency_name as currency,
              pricings_fees.rate,
              pricings_fees.base,
              pricings_fees.charge_category_id,
              pricings_fees.min,
              pricings_fees.range,
              pricings_fees.metadata,
              pricings_pricings.wm_rate as cbm_ratio,
              pricings_pricings.vm_rate as vm_ratio,
              tenant_vehicles.carrier_lock,
              tenant_vehicles.carrier_id
              ").as_json
          end

          def fees
            @fees ||= ::Pricings::Fee.where(pricing: record)
              .joins(:charge_category)
              .joins(:rate_basis)
              .joins(pricing: :itinerary)
              .joins(pricing: :tenant_vehicle)
          end

          def base_row
            @base_row ||= { "margin_type" => MARGIN_TYPE, "source_type" => record.class.name }
          end

          class PricingFeeRow
            def initialize(fee_row:)
              @fee_row = fee_row
            end

            attr_reader :fee_row

            def perform
              value_keys.product(range).map do |value_key, range_row|
                pricing_fee_row.merge(range_row.slice("rate"))
                  .merge(fee_range(value_key: value_key, range: range_row))
              end
            end

            def value_keys
              @value_keys ||= OfferCalculator::Service::Charges::Support::ValueKeys.new(fee: pricing_fee_row).value_keys
            end

            def range
              range_data = fee_row.delete("range")
              range_data = [{}] if range_data.blank?
              range_data
            end

            def fee_range(value_key:, range:)
              {
                "range_min" => range["min"] || 0,
                "range_max" => range["max"] || Float::INFINITY,
                "range_unit" => value_key,
                "section" => "cargo"
              }
            end

            def pricing_fee_row
              fee_row["rate_basis"] = rate_basis
              fee_row["effective_date"] = fee_row.delete("effective_date").to_date
              fee_row["expiration_date"] = fee_row.delete("expiration_date").to_date
              fee_row["cbm_ratio"] ||= ::Pricings::Pricing::WM_RATIO_LOOKUP[fee_row["mode_of_transport"].to_sym]
              fee_row["vm_ratio"] ||= 1
              fee_row.merge("source_id" => fee_row["context_id"])
            end

            def rate_basis
              @rate_basis ||= OfferCalculator::Service::Charges::Support::RateBasisData.new(
                fee: fee_row.merge("rate_basis" => fee_row.delete("rate_basis_name"))
              ).rate_basis
            end
          end
        end
      end
    end
  end
end
