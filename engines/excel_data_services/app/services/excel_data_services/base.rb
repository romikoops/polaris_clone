# frozen_string_literal: true

module ExcelDataServices
  class Base
    MOT_HUB_NAME_LOOKUP =
      {"ocean" => "Port",
       "air" => "Airport",
       "rail" => "Railyard",
       "truck" => "Depot"}.freeze

    def find_hub_by_name_or_locode_with_info(name:, country:, mot:, locode:)
      if locode.is_a?(String)
        nexus = find_nexus_by_locode_or_name(locode: locode, name: name, country: country)
        hub = find_hub_by_name_and_mot(name: name, country: country, mot: mot, nexus: nexus)
        found_by_info = locode
      end

      if !hub && name
        hub = find_hub_by_name_and_mot(name: name, country: country, mot: mot)
        found_by_info = [name, country].compact.join(", ")
      end

      {hub: hub, found_by_info: found_by_info}
    end

    private

    def find_hub_by_name_and_mot(name:, country:, mot:, nexus: nil)
      hubs = ::Legacy::Hub.where(organization: organization, hub_type: mot)
      hubs = hubs.where(nexus: nexus) if nexus.present?
      hubs = hubs.where(name: name) if name.present?

      if country.present?
        hubs.joins(:country).find_by(countries: {name: country})
      else
        hubs.first
      end
    end

    def find_nexus_by_locode_or_name(locode:, name:, country:)
      safe_locode = locode.delete(" ").upcase
      nexuses = ::Legacy::Nexus.where(organization: organization)

      nexuses = nexuses.joins(:country).where(countries: {name: country}) if country.present?
      nexus = nexuses.find_by(name: name, locode: safe_locode)
      nexus || nexuses.find_by(locode: safe_locode)
    end
  end
end
