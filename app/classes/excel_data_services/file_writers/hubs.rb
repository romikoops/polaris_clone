# frozen_string_literal: true

module ExcelDataServices
  module FileWriters
    class Hubs < ExcelDataServices::FileWriters::Base
      private

      def load_and_prepare_data
        hubs = Hub.where(organization: organization, sandbox: @sandbox)

        { 'Hubs' => prepare_hub_data(hubs: hubs) }
      end

      def prepare_hub_data(hubs:)
        hubs.map do |hub|
          nexus = hub.nexus
          address = hub.address
          mandatory_charge = hub.mandatory_charge

          {
            status: hub.hub_status,
            type: hub.hub_type,
            name: nexus.name,
            locode: nexus.locode,
            latitude: hub.latitude,
            longitude: hub.longitude,
            country: address.country&.name,
            full_address: address.geocoded_address,
            free_out: hub.free_out.to_s,
            import_charges: mandatory_charge&.import_charges.to_s,
            export_charges: mandatory_charge&.export_charges.to_s,
            pre_carriage: mandatory_charge&.pre_carriage.to_s,
            on_carriage: mandatory_charge&.on_carriage.to_s,
            alternative_names: ''
          }
        end
      end

      def build_raw_headers(_sheet_name, _rows_data)
        HEADER_COLLECTION::HUBS
      end
    end
  end
end
