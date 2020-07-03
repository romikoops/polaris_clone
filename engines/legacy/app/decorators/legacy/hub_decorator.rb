# frozen_string_literal: true

module Legacy
  class HubDecorator < Draper::Decorator
    delegate_all

    def name
      return super unless scope.dig(:append_hub_suffix)

      suffix = scope.dig(:hub_suffixes, hub_type) || Legacy::Hub::MOT_HUB_NAME[hub_type]
      [super, suffix].compact.join(" ")
    end

    def legacy_json
      as_json({
        include: {
          nexus: {only: %i[id name]},
          address: {
            include: {
              country: {only: %i[name]}
            }
          }
        },
        methods: [:name]
      })
    end

    def legacy_index_json
      legacy_json.merge(earliest_expiration: earliest_expiration)
    end

    def shipment_legacy_json
      as_json({
        include: {address: {only: %i[geocoded_address latitude longitude]}},
        methods: [:name]
      })
    end

    def select_option
      { label: name, value: legacy_index_json }
    end

    private

    def scope
      context&.dig(:scope) || {}
    end
  end
end
