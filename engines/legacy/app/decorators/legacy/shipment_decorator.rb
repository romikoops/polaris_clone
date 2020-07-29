# frozen_string_literal: true

class Legacy::ShipmentDecorator < Draper::Decorator
  delegate_all

  delegate :external_id, to: :shipment_user_profile

  def origin
    origin_nexus&.locode || pickup_postal_code || origin_city
  end

  def destination
    destination_nexus&.locode || delivery_postal_code || destination_city
  end

  def origin_city
    has_pre_carriage? ? pickup_address.city : origin_nexus.name
  end

  def origin_locode
    origin_nexus&.locode
  end

  def destination_city
    has_on_carriage? ? delivery_address.city : destination_nexus.name
  end

  def destination_locode
    destination_nexus&.locode
  end

  def pickup_postal_code
    return unless has_pre_carriage?

    pickup_address&.zip_code.present? ? "#{pickup_address.country.code}-#{pickup_address&.zip_code}" : nil
  end

  def delivery_postal_code
    return unless has_on_carriage?

    delivery_address&.zip_code.present? ? "#{delivery_address.country.code}-#{delivery_address&.zip_code}" : nil
  end

  def total_weight
    return aggregated_cargo.weight.to_i if aggregated_cargo.present?

    cargo_units.sum { |unit| unit.payload_in_kg * unit.quantity }.to_i
  end

  def total_volume
    return unless lcl?
    return aggregated_cargo.volume.round(2) if aggregated_cargo.present?

    cargo_items.sum { |unit| unit.volume * unit.quantity }.round(2)
  end

  def routing
    [
      has_pre_carriage? ? pickup_address.city : origin_nexus.name,
      has_on_carriage? ? delivery_address.city : destination_nexus.name
    ].join(" - ")
  end

  def load_type
    super == "cargo_item" ? "LCL" : "FCL"
  end

  def legacy_json(offer_args: {})
    as_json(
      methods: %i[mode_of_transport cargo_count company_name client_name],
      include: [
        :destination_nexus,
        :origin_nexus
      ]
    ).merge(
      origin_hub: origin_hub&.shipment_legacy_json,
      destination_hub: destination_hub&.shipment_legacy_json
    )
  end

  def legacy_address_json(offer_args: {})
    legacy_json.merge(
      pickup_address: pickup_address_with_country,
      delivery_address: delivery_address_with_country,
      selected_offer: selected_offer(offer_args)
    )
  end

  def legacy_index_json(offer_args: {})
    legacy_json.merge(
      pickup_address: pickup_address_with_country,
      delivery_address: delivery_address_with_country
    )
  end

  def origin_hub
    decorated_hub(hub: super)
  end

  def destination_hub
    decorated_hub(hub: super)
  end

  private

  def scope
    context&.dig(:scope) || {}
  end

  def decorated_hub(hub:)
    return if hub.blank?

    Legacy::HubDecorator.new(hub, context: {scope: scope})
  end
end
