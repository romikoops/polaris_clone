# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      module RecordData
        class Trucking
          attr_reader :record

          def initialize(record:)
            @record = record
          end

          def perform
            OfferCalculator::Service::Charges::Support::ChargeCategoryData.new(
              frame: Rover::DataFrame.new(trucking_fee_rows + trucking_rate_rows)
            ).perform
          end

          private

          delegate :carriage, :hub_id, :validity, :location, :load_meterage, :id, :tenant_vehicle, :fees, :cargo_class, to: :record

          def trucking_rate_rows
            record.rates.flat_map do |modifier, rates|
              rates.map { |rate| rate_data(rate: rate, modifier: modifier) }.flatten
            end
          end

          def trucking_fee_rows
            @trucking_fee_rows ||= OfferCalculator::Service::Charges::Support::FeeExpansion.new(
              fees: fees, base: trucking_info
            ).perform
          end

          def trucking_info
            @trucking_info ||= record.slice("cbm_ratio", "tenant_vehicle_id", "cargo_class", "load_type", "organization_id").merge(
              "origin_hub_id" => carriage == "on" ? hub_id : nil,
              "destination_hub_id" => carriage == "pre" ? hub_id : nil,
              "section" => "trucking_#{carriage}",
              "direction" => carriage == "pre" ? "export" : "import",
              "margin_type" => "trucking_#{carriage}_margin",
              "effective_date" => validity.first,
              "expiration_date" => validity.last,
              "vm_ratio" => 1,
              "context_id" => id,
              "source_type" => record.class.name,
              "carrier_lock" => tenant_vehicle.carrier_lock,
              "km" => location.query == "distance" ? location.data : nil
            ).merge(load_meterage_data)
          end

          def load_meterage_data
            load_meterage.transform_keys { |key| "load_meterage_#{key}" }
          end

          def rate_data(rate:, modifier:)
            fee_values = {
              "min" => rate["min_value"],
              "rate" => rate["rate"].values_at("rate", "value").compact.map(&:to_d).first,
              "code" => "trucking_#{cargo_class}",
              "rate_basis" => rate.dig("rate", "rate_basis")
            }.merge(rate["rate"].slice("base", "currency"))
              .merge(fee_range(value_key: modifier, range: rate))

            OfferCalculator::Service::Charges::Support::ExpandedFee.new(
              fee: fee_values,
              base: trucking_info
            ).perform
          end

          def fee_range(value_key:, range:)
            {
              "range_min" => range.values_at("min_#{value_key}", "range_min").find(&:present?)&.to_d || 0,
              "range_max" => range.values_at("max_#{value_key}", "range_max").find(&:present?)&.to_d || Float::INFINITY,
              "range_unit" => value_key
            }
          end
        end
      end
    end
  end
end
