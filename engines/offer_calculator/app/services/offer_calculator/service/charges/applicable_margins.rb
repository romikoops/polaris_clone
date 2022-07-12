# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class ApplicableMargins
        def initialize(type:, applicables:, period:, cargo_classes:, expansion_value:)
          @type = type
          @applicables = applicables
          @period = period
          @cargo_classes = cargo_classes
          @expansion_value = expansion_value
        end

        def frame
          @frame ||= base_margin_frame.concat(expanded_frame).inner_join(applicable_frame, on: {
            "applicable_type" => "applicable_type",
            "applicable_id" => "applicable_id"
          }).sort_by! { |row| row["rank"] }
        end

        private

        attr_reader :applicables, :type, :period, :cargo_classes, :expansion_value

        def base_margin_frame
          Rover::DataFrame.new({
            "id" => [],
            "rate" => [],
            "operator" => [],
            "code" => [],
            "margin_id" => [],
            "applicable_id" => [],
            "applicable_type" => [],
            "effective_date" => [],
            "expiration_date" => [],
            "origin_hub_id" => [],
            "destination_hub_id" => [],
            "itinerary_id" => [],
            "tenant_vehicle_id" => [],
            "pricing_id" => [],
            "cargo_class" => [],
            "currency" => [],
            "range_min" => [],
            "range_max" => [],
            "range_unit" => [],
            "margin_type" => [],
            "source_type" => []
          })
        end

        def expanded_frame
          @expanded_frame ||= base_margin_frame.concat(extracted_frame)
            .left_join(margin_type_frame, on: { "margin_type" => "original_margin_type" })
            .left_join(cargo_class_frame, on: { "cargo_class" => "expansion_value" })
            .tap do |frame|
            frame.delete("expansion_value")
            frame.delete("original_margin_type")
          end
        end

        def applicable_frame
          @applicable_frame ||= Rover::DataFrame.new(
            applicables.map.with_index do |applicable, rank|
              {
                "rank" => rank,
                "applicable_id" => applicable.id,
                "applicable_type" => applicable.class.to_s
              }
            end
          )
        end

        def extracted_frame
          @extracted_frame ||= Rover::DataFrame.new(
            applicable_margins.select("
              COALESCE(pricings_details.id, pricings_margins.id) as id,
              COALESCE(pricings_details.value, pricings_margins.value)::float as rate,
              COALESCE(pricings_details.operator, pricings_margins.operator) as operator,
              COALESCE(charge_categories.code, '#{expansion_value}') as code,
              pricings_details.margin_id,
              pricings_details.charge_category_id,
              pricings_margins.applicable_id,
              pricings_margins.applicable_type,
              pricings_margins.effective_date::date,
              pricings_margins.expiration_date::date,
              pricings_margins.origin_hub_id,
              pricings_margins.destination_hub_id,
              pricings_margins.itinerary_id,
              pricings_margins.tenant_vehicle_id,
              pricings_margins.pricing_id,
              COALESCE(pricings_margins.cargo_class, '#{expansion_value}') as cargo_class,
              pricings_margins.margin_type
            ").as_json.map do |margin|
              operator = margin["operator"]
              margin["effective_date"] = margin.delete("effective_date").to_date
              margin["expiration_date"] = margin.delete("expiration_date").to_date
              margin["rate_basis"] = margin_rate_basis[operator]
              margin["range_unit"] = margin_range_unit[operator]
              margin["range_min"] = 0
              margin["range_max"] = Float::INFINITY
              margin["currency"] = margin_currency
              margin["source_type"] = margin["margin_id"].present? ? "Pricings::Detail" : "Pricings::Margin"
              margin
            end
          )
        end

        def applicable_margins
          @applicable_margins ||= non_default_margins.presence || default_margins
        end

        def non_default_margins
          @non_default_margins ||= margins.where(default_for: nil, applicable: applicables)
        end

        def default_margins
          @default_margins ||= margins.where(applicable: organization).where.not(default_for: nil)
        end

        def margins
          @margins ||= ::Pricings::Margin
            .left_joins(details: :charge_category)
            .includes(:details)
            .includes(details: :charge_category)
            .includes(:applicable)
            .where(
              margin_type: margin_types,
              organization_id: organization.id
            )
            .for_dates(period.first, period.last)
        end

        def margin_types
          {
            "Pricing" => %w[freight_margin total_margin],
            "LocalCharge" => %w[export_margin import_margin total_margin],
            "Trucking" => %w[trucking_pre_margin trucking_on_margin total_margin]
          }[type]
        end

        def organization
          @organization ||= Organizations::Organization.current
        end

        def margin_rate_basis
          {
            "%" => "PERCENTAGE",
            "+" => "PER_SHIPMENT",
            "&" => "PER_UNIT"
          }
        end

        def margin_range_unit
          {
            "%" => "percentage",
            "+" => "shipment",
            "&" => "unit"
          }
        end

        def margin_currency
          @margin_currency ||= organization.scope.default_currency
        end

        def cargo_class_frame
          @cargo_class_frame ||= Rover::DataFrame.new({
            "cargo_class" => cargo_classes,
            "expansion_value" => ["All"] * cargo_classes.count
          })
        end

        def margin_type_frame
          @margin_type_frame ||= Rover::DataFrame.new({
            "original_margin_type" => ["total_margin"] * non_total_margin_types.count,
            "margin_type" => non_total_margin_types
          })
        end

        def non_total_margin_types
          @non_total_margin_types ||= margin_types - ["total_margin"]
        end
      end
    end
  end
end
