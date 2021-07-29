# frozen_string_literal: true

module ExcelDataServices
  class Base
    MOT_HUB_NAME_LOOKUP =
      { "ocean" => "Port",
        "air" => "Airport",
        "rail" => "Railyard",
        "truck" => "Depot" }.freeze

    def find_hub_by_name_or_locode_with_info(name:, country:, mot:, locode:, terminal: nil)
      locode = locode.delete(" ").upcase if locode.present?
      nexus = find_nexus_by_locode_or_name(name: name, country: country, locode: locode)
      hub = find_hub_by_name_and_mot(name: name, country: country, mot: mot, nexus: nexus, locode: locode, terminal: terminal) if nexus.present?

      { hub: hub, found_by_info: [name, country, locode, terminal].compact.join(", ") }
    end

    private

    attr_reader :organization

    def find_nexus_by_locode_or_name(name:, country:, locode:)
      nexuses = ::Legacy::Nexus.where(organization: organization)
      nexuses.find_by(locode: locode) || nexuses.joins(:country).find_by(name: name, countries: { name: country })
    end

    def find_hub_by_name_and_mot(name:, country:, mot:, nexus:, locode:, terminal: nil)
      hubs = ::Legacy::Hub.where(organization: organization, hub_type: mot, nexus: nexus, terminal: terminal)
      hubs.find_by(name: name) || hubs.find_by(hub_code: locode)
    end
  end
end
