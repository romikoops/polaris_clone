# frozen_string_literal: true

module ExcelDataServices
  class Base
    MOT_HUB_NAME_LOOKUP =
      { "ocean" => "Port",
        "air" => "Airport",
        "rail" => "Railyard",
        "truck" => "Depot" }.freeze

    def find_hub_by_name_or_locode_with_info(name:, country:, mot:, locode:)
      locode = locode.delete(" ").upcase if locode.present?
      nexus = find_nexus_by_locode_or_name(name: name, country: country, locode: locode)
      hub = find_hub_by_name_and_mot(name: name, country: country, mot: mot, nexus: nexus, locode: locode) if nexus.present?

      { hub: hub, found_by_info: [name, country, locode].compact.join(", ") }
    end

    private

    attr_reader :organization

    def find_nexus_by_locode_or_name(name:, country:, locode:)
      nexuses = ::Legacy::Nexus.where(organization: organization)
      nexus = nexuses.joins(:country).find_by(name: name, countries: { name: country }) if name.present? && country.present?

      nexus || nexuses.find_by(locode: locode)
    end

    def find_hub_by_name_and_mot(name:, country:, mot:, nexus:, locode:)
      hubs = ::Legacy::Hub.where(organization: organization, hub_type: mot, nexus: nexus)
      hub = hubs.joins(:country).find_by(name: name, countries: { name: country }) if name.present? && country.present?

      hub || hubs.find_by(hub_code: locode)
    end
  end
end
