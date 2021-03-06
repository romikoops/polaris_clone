# frozen_string_literal: true

module Pricings
  class ManipulatorResult
    attr_reader :result, :breakdowns, :original, :flat_margins

    delegate :id, :organization, :tenant_vehicle_id, to: :original

    def initialize(original:, result:, breakdowns: [], flat_margins: {})
      @original = original
      @result = result
      @breakdowns = initial_breakdowns + breakdowns
      @flat_margins = flat_margins
    end

    def direction
      return nil if original.is_a?(::Pricings::Pricing)
      return original.carriage == "pre" ? "export" : "import" if original.is_a?(Trucking::Trucking)
      return original.direction if original.is_a?(::Legacy::LocalCharge)
    end

    def service
      @service ||= original.tenant_vehicle
    end

    def validity
      Range.new(effective_date.to_date, expiration_date.to_date + 1.day, exclude_end: true)
    end

    def cbm_ratio
      result["cbm_ratio"] || result["wm_rate"] || Pricings::Pricing::WM_RATIO_LOOKUP[mot.to_sym]
    end

    def vm_ratio
      result["vm_rate"] || 1
    end

    def load_meterage_ratio
      result.dig("load_meterage", "ratio") || 0
    end

    def fees
      result["data"] || result["fees"]
    end

    def type
      original.class.to_s
    end

    def section
      case original.class.to_s
      when "Pricings::Pricing"
        "cargo"
      when "Legacy::LocalCharge"
        original.direction
      when "Trucking::Trucking"
        "trucking_#{original.carriage}"
      end
    end

    def cargo_class
      case original.class.to_s
      when "Legacy::LocalCharge"
        original.load_type
      else
        original.cargo_class
      end
    end

    def load_type
      case original.class.to_s
      when "Legacy::LocalCharge"
        original.load_type == "lcl" ? "cargo_item" : "container"
      else
        original.load_type
      end
    end

    def load_meterage_limit(type:)
      result.dig("load_meterage", [type, "limit"].join("_")) || result.dig("load_meterage", load_meterage_type(type: type))
    end

    def load_meterage_hard_limit
      result.dig("load_meterage", "hard_limit")
    end

    def load_meterage_stacking
      result.dig("load_meterage", "stacking")
    end

    def load_meterage_type(type:)
      result.dig("load_meterage", [type, "type"].join("_")) ||
        (result["load_meterage"] || {}).slice("height_limit", "area_limit", "ldm_limit").entries.find { |entry| entry.second.present? }&.first ||
        "none"
    end

    def distance
      location = Trucking::Location.find_by(id: result["location_id"])
      km = location&.query == "distance" ? location.data : 0
      Measured::Length.new(km, "km")
    end

    def effective_date
      result["effective_date"]
    end

    def expiration_date
      result["expiration_date"]
    end

    def truck_type
      return unless original.is_a? Trucking::Trucking

      original.truck_type
    end

    def itinerary_id
      return unless original.is_a?(Pricings::Pricing)

      original.itinerary_id
    end

    def hub_id
      return if original.is_a?(Pricings::Pricing)

      original.hub_id
    end

    alias km distance

    private

    def initial_breakdowns
      case original.class.to_s
      when "Pricings::Pricing"
        pricing_breakdowns
      when "Legacy::LocalCharge"
        json_breakdowns
      when "Trucking::Trucking"
        json_breakdowns | trucking_rate_breakdown
      end
    end

    def pricing_breakdowns
      original.fees.map do |fee|
        Pricings::ManipulatorBreakdown.new(
          data: fee.fee_data,
          metadata: fee.metadata.merge(rate_origin_data),
          charge_category: fee.charge_category,
          delta: nil
        )
      end
    end

    def json_breakdowns
      original.fees.map do |fee_key, fee_data|
        charge_category = charge_category(key: fee_key)
        Pricings::ManipulatorBreakdown.new(
          data: fee_data,
          metadata: original.metadata.merge(rate_origin_data),
          charge_category: charge_category,
          delta: nil
        )
      end
    end

    def trucking_rate_breakdown
      charge_category = ::Legacy::ChargeCategory.from_code(
        organization_id: organization.id,
        code: "trucking_#{original.cargo_class}"
      )
      [Pricings::ManipulatorBreakdown.new(
        data: original.rates,
        metadata: rate_origin_data.merge(original.metadata || {}),
        charge_category: charge_category,
        delta: nil
      )]
    end

    def charge_category(key:)
      ::Legacy::ChargeCategory.find_by(code: key.downcase, organization_id: original.organization_id)
    end

    def mot
      case original.class.to_s
      when "Pricings::Pricing"
        ::Legacy::Itinerary.find(itinerary_id).mode_of_transport
      when "Legacy::LocalCharge"
        original.mode_of_transport
      when "Trucking::Trucking"
        original.hub.hub_type
      end
    end

    def rate_origin_data
      {
        id: original.id,
        type: original.class.to_s
      }
    end
  end
end
