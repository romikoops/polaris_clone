# frozen_string_literal: true

module ExcelDataServices
  module FileWriters
    class Hubs < ExcelDataServices::FileWriters::Base
      private

      def load_and_prepare_data
        { "Hubs" => prepared_hub_data }
      end

      def prepared_hub_data
        Rover::DataFrame.new(
          Legacy::Hub.where(organization: organization)
          .joins(nexus: :country)
          .joins(:mandatory_charge)
          .left_joins(:address)
          .select("
            hubs.hub_status as status,
            hubs.hub_type as type,
            hubs.name as name,
            nexuses.locode as locode,
            hubs.terminal as terminal,
            hubs.terminal_code as terminal_code,
            hubs.latitude as latitude,
            hubs.longitude as longitude,
            countries.name as country,
            addresses.geocoded_address as full_address,
            hubs.free_out::text as free_out,
            mandatory_charges.import_charges::text as import_charges,
            mandatory_charges.export_charges::text as export_charges,
            mandatory_charges.pre_carriage::text as pre_carriage,
            mandatory_charges.on_carriage::text as on_carriage,
            '' as alternative_names
          ")
        ).to_a.map(&:symbolize_keys!)
      end

      def build_raw_headers(_sheet_name, _rows_data)
        HEADER_COLLECTION::HUBS.keys
      end
    end
  end
end
