# frozen_string_literal: true

module DataWriter
  class LocalChargesWriter < BaseWriter
    private

    def load_and_prepare_data
      rows_data = []
      tenant.local_charges.each do |local_charge|
        local_charge[:fees].each do |_fee_code, fee_values_h|
          rows_data << build_row_data(local_charge, fee_values_h)
        end
      end

      { "Sheet1": rows_data }
    end

    def build_row_data(local_charge, fee)
      hub = tenant.hubs.find(local_charge.hub_id)
      hub_name = remove_hub_suffix(hub.name, hub.hub_type)
      country_name = hub.address.country.name
      counterpart_hub = tenant.hubs.find_by(id: local_charge.counterpart_hub_id) # soft find
      counterpart_hub_name = remove_hub_suffix(counterpart_hub.name, counterpart_hub.hub_type) if counterpart_hub
      counterpart_country_name = counterpart_hub.address.country.name if counterpart_hub
      tenant_vehicle = local_charge.tenant_vehicle
      service_level = tenant_vehicle.name
      carrier = tenant_vehicle.carrier.name

      {
        hub: hub_name,
        country: country_name,
        effective_date: Date.parse(fee['effective_date']).strftime("%d.%m.%Y"),
        expiration_date: Date.parse(fee['expiration_date']).strftime("%d.%m.%Y"),
        counterpart_hub_name: counterpart_hub_name,
        counterpart_country: counterpart_country_name,
        service_level: service_level,
        carrier: carrier,
        fee_code: fee['key'],
        fee: fee['name'],
        mot: local_charge.mode_of_transport,
        load_type: local_charge.load_type,
        direction: local_charge.direction,
        currency: fee['currency'],
        rate_basis: fee['rate_basis'],
        minimum: fee['min'],
        maximum: fee['max'],
        base: fee['base'],
        ton: fee['ton'],
        cbm: fee['cbm'],
        kg: fee['kg'],
        item: fee['item'],
        shipment: fee['shipment'],
        bill: fee['bill'],
        container: fee['container'],
        wm: fee['wm'],
        range_min: fee['range_min'],
        range_max: fee['range_max'],
        dangerous: local_charge.dangerous
      }
    end
  end
end
