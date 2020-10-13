# frozen_string_literal: true

module Pdf
  class CarrierServiceInfo
    attr_reader :tender, :carriage, :voyage_info

    def initialize(tender:, carriage:, voyage_info: {})
      @tender = tender
      @carriage = carriage
      @voyage_info = voyage_info
    end

    def operator
      return "" if voyage_info.slice(service_key, carrier_key).values.none?

      if show_combination?
        "#{carrier_name}(#{service.name})"
      elsif show_service?
        service.name
      elsif show_carrier?
        carrier_name
      end
    end

    def carrier_key
      "#{carriage}_carriage_carrier"
    end

    def service_key
      "#{carriage}_carriage_service"
    end

    def show_carrier?
      voyage_info[carrier_key].present?
    end

    def show_service?
      voyage_info[service_key].present?
    end

    def show_combination?
      show_carrier? && show_service?
    end

    def carrier_name
      @carrier_name ||= service.carrier&.name
    end

    def service
      @service ||= carriage == "pre" ? tender.pickup_tenant_vehicle : tender.delivery_tenant_vehicle
    end
  end
end
