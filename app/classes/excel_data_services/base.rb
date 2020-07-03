# frozen_string_literal: true

module ExcelDataServices
  class Base
    MOT_HUB_NAME_LOOKUP =
      { 'ocean' => 'Port',
        'air' => 'Airport',
        'rail' => 'Railyard',
        'truck' => 'Depot' }.freeze

    def find_hub_by_name_or_locode_with_info(name:, country:, mot:, locode:)
      if name
        hub = find_hub_by_name_and_mot(raw_name: name, country: country, mot: mot)
        found_by_info = [name, country].compact.join(', ')
      end

      if !hub && locode.is_a?(String)
        nexus = ::Legacy::Nexus.find_by(organization: organization, locode: locode.delete(' ').upcase)
        hub = find_hub_by_name_and_mot(raw_name: nexus.name, country: country, mot: mot) if nexus
        found_by_info = locode
      end

      { hub: hub, found_by_info: found_by_info }
    end

    private

    def find_hub_by_name_and_mot(raw_name:, country:, mot:)
      hubs = ::Legacy::Hub.where(organization: organization, hub_type: mot, name: raw_name)

      if country.present?
        hubs.joins(:country).find_by(countries: { name: country })
      else
        hubs.first
      end
    end
  end
end
