# frozen_string_literal: true

module OfferCalculator
  module Service
    class CargoCreator
      attr_reader :params, :query, :persist

      def initialize(query:, params:, persist: true)
        @query = query
        @params = params
        @persist = persist
      end

      def perform
        (cargo_units + [aggregated_cargo]).compact
      rescue ActiveRecord::RecordInvalid
        raise OfferCalculator::Errors::InvalidCargoUnit
      end

      alias_method :persist?, :persist

      private

      def cargo_units
        cargo_units_params.map { |unit_params| journey_cargo(unit_params: unit_params) }
      end

      def cargo_units_params
        params.dig("cargo_items_attributes").presence || params.dig("containers_attributes") || []
      end

      def journey_cargo(unit_params:)
        return if unit_params.blank?
        Journey::CargoUnit.new(
          id: unit_params_id(unit_params: unit_params),
          weight_value: unit_params.dig("payload_in_kg") || 0,
          width_value: dimension_from_params(unit_params: unit_params, dimension: "width"),
          length_value: dimension_from_params(unit_params: unit_params, dimension: "length"),
          height_value: dimension_from_params(unit_params: unit_params, dimension: "height"),
          quantity: unit_params.dig("quantity") || 1,
          stackable: unit_params.dig(:stackable).present?,
          query: query,
          colli_type: colli_type(unit_params: unit_params),
          cargo_class: cargo_class_from_params(unit_params: unit_params)
        ).tap do |new_cargo|
          return new_cargo unless persist?
          new_cargo.commodity_infos << commodity_info_for_cargo(unit: new_cargo, unit_params: unit_params)
          new_cargo.save
        end
      end

      def cargo_class_from_params(unit_params:)
        unit_params.dig("size_class") || "lcl"
      end

      def colli_type(unit_params:)
        legacy_type = Legacy::CargoItemType.find_by(id: unit_params["cargo_item_type_id"])
        return :pallet if legacy_type.blank?

        case legacy_type.category
        when /Drum/
          :drum
        when /Carton/
          :carton
        when /(15-25C)/
          :room_temp_reefer
        when /(2-8C)/
          :low_temp_reefer
        else
          legacy_type.category.downcase.to_sym
        end
      end

      def dimension_from_params(unit_params:, dimension:)
        return 0 if unit_params.dig(dimension).blank?

        unit_params.dig(dimension).to_d / 100.0
      end

      def aggregated_cargo
        return if params.dig("aggregated_cargo").blank?

        Journey::CargoUnit.new(
          id: unit_params_id(unit_params: unit_params),
          weight_value: params.dig("aggregated_cargo", "weight"),
          width_value: 1,
          length_value: params.dig("aggregated_cargo", "volume"),
          height_value: 1,
          quantity: 1,
          stackable: true,
          query: query,
          cargo_class: "aggregated_lcl"
        ).tap do |new_cargo|
          return new_cargo unless persist?
          new_cargo.save
        end
      end

      def commodity_info_for_cargo(unit_params:, unit:)
        return [] if unit_params["dangerous_goods"].blank?

        Journey::CommodityInfo.new(
          cargo_unit: unit,
          imo_class: "0",
          hs_code: "",
          description: "Unknown Dangerous Goods"
        )
      end

      def unit_params_id(unit_params:)
        return if persist?

        unit_params["id"]
      end
    end
  end
end
