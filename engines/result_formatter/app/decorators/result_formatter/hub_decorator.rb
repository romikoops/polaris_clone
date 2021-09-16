# frozen_string_literal: true

module ResultFormatter
  class HubDecorator < ApplicationDecorator
    delegate_all

    def name
      return name_with_suffix if terminal.blank?

      "#{name_with_suffix} (#{terminal})"
    end

    def name_with_suffix
      return original_name if !append_suffix? || original_name.ends_with?(suffix)

      [original_name, suffix].compact.join(" ")
    end

    def legacy_json
      as_json({
        include: {
          nexus: { only: %i[id name] },
          address: {
            include: {
              country: { only: %i[name] }
            }
          }
        },
        methods: [:name]
      })
    end

    def legacy_index_json
      legacy_json.merge(earliest_expiration: earliest_expiration)
    end

    def select_option
      { label: name, value: legacy_index_json }
    end

    private

    def scope
      context.fetch(:scope, {})
    end

    def original_name
      object.name
    end

    def suffix
      scope.dig(:hub_suffixes, hub_type) || Legacy::Hub::MOT_HUB_NAME[hub_type]
    end

    def append_suffix?
      scope[:append_hub_suffix]
    end
  end
end
