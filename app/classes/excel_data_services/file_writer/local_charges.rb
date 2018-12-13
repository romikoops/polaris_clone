# frozen_string_literal: true

module ExcelDataServices
  module FileWriter
    class LocalCharges < Base
      include ExcelDataServices::LocalChargesTool

      def initialize(tenant:, file_name:, mode_of_transport: nil)
        super(tenant: tenant, file_name: file_name)
        @mode_of_transport = mode_of_transport
      end

      private

      attr_reader :mode_of_transport

      def load_and_prepare_data
        rows_data = []
        local_charges = mode_of_transport ? tenant.local_charges.for_mode_of_transport(mode_of_transport) : tenant.local_charges
        local_charges&.each do |local_charge|
          local_charge[:fees].values.each do |fee_values_h|
            rows_data << build_row_data(local_charge, fee_values_h)
          end
        end

        sort!(rows_data)

        { 'Sheet1' => rows_data }
      end

      def build_row_data(local_charge, fee)
        fee.deep_symbolize_keys!
        hub = tenant.hubs.find(local_charge.hub_id)
        hub_name = remove_hub_suffix(hub.name, hub.hub_type)
        country_name = hub.address.country.name
        effective_date = Date.parse(fee[:effective_date].to_s) if fee[:effective_date]
        expiration_date = Date.parse(fee[:expiration_date].to_s) if fee[:expiration_date]
        counterpart_hub = tenant.hubs.find_by(id: local_charge.counterpart_hub_id) # find_by returns nil if `id` not available
        counterpart_hub_name = remove_hub_suffix(counterpart_hub.name, counterpart_hub.hub_type) if counterpart_hub
        counterpart_country_name = counterpart_hub.address.country.name if counterpart_hub
        tenant_vehicle = local_charge.tenant_vehicle
        service_level = tenant_vehicle.name
        carrier = tenant_vehicle.carrier&.name
        rate_basis = fee[:rate_basis]

        charge_params = specific_charge_params_for_writing(rate_basis, fee)

        {
          hub: hub_name,
          country: country_name,
          effective_date: effective_date,
          expiration_date: expiration_date,
          counterpart_hub_name: counterpart_hub_name,
          counterpart_country: counterpart_country_name,
          service_level: service_level,
          carrier: carrier,
          fee_code: fee[:key],
          fee: fee[:name],
          mot: local_charge.mode_of_transport,
          load_type: local_charge.load_type,
          direction: local_charge.direction,
          currency: fee[:currency],
          rate_basis: fee[:rate_basis],
          minimum: fee[:min],
          maximum: fee[:max],
          **charge_params,
          dangerous: local_charge.dangerous
        }
      end

      def sort!(data)
        data.sort_by! do |h|
          [
            h[:mot] || '',
            h[:direction] || '',
            h[:country] || '',
            h[:hub] || '',
            h[:counterpart_country] || '',
            h[:counterpart_hub_name] || '',
            h[:load_type] || '',
            h[:effective_date] || '',
            h[:expiration_date] || '',
            h[:carrier] || '',
            h[:service_level] || '',
            h[:rate_basis] || '',
            h[:fee_code] || '',
            h[:fee] || '',
            h[:minimum] || '',
            h[:maximum] || '',
            h[:currency] || '',
            h[:range_min] || '',
            h[:range_max] || '',
            h[:dangerous] ? 1 : -1
          ]
        end
      end

      def build_raw_headers(_sheet_name, _rows_data)
        VALID_STATIC_HEADERS
      end
    end
  end
end
