# frozen_string_literal: true

module ExcelDataServices
  class Base
    MOT_HUB_NAME_LOOKUP =
      { 'ocean' => 'Port',
        'air' => 'Airport',
        'rail' => 'Railyard',
        'truck' => 'Depot' }.freeze

    def find_hub_by_name_or_locode_with_info(raw_name:, mot:, locode:)
      if raw_name
        hub = find_hub_by_name_and_mot(raw_name, mot)
        found_by_info = raw_name
      end

      if !hub && locode
        nexus = ::Legacy::Nexus.find_by(tenant: tenant, locode: locode.delete(' ').upcase, sandbox: @sandbox)
        hub = find_hub_by_name_and_mot(nexus.name, mot) if nexus
        found_by_info = locode
      end

      { hub: hub, found_by_info: found_by_info }
    end

    def append_hub_suffix(raw_name, mot)
      return if raw_name.blank?

      return raw_name if mot.blank?

      "#{raw_name} #{MOT_HUB_NAME_LOOKUP[mot.downcase]}"
    end

    def find_hub_by_name_and_mot(raw_name, mot)
      hub_name = append_hub_suffix(raw_name, mot)
      ::Legacy::Hub.find_by(tenant: tenant, name: hub_name, sandbox: @sandbox)
    end
  end
end
