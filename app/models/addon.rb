# frozen_string_literal: true

class Addon < Legacy::Addon
  belongs_to :hub

  def self.prepare_addons(origin_hub, destination_hub, cargo_class, tenant_vehicle_id, mot, cargos, user)
    addons = determine_addons(origin_hub, destination_hub, cargo_class, tenant_vehicle_id, mot, user)
    condensed_addons = condense_addons(addons, cargos, user, mot)
  end

  private

  def self.determine_addons(origin_hub, destination_hub, cargo_class, tenant_vehicle_id, mot, user)
    counterpart_origin_addons = origin_hub.addons.where(
      cargo_class: cargo_class,
      counterpart_hub_id: destination_hub.id,
      tenant_vehicle_id: tenant_vehicle_id,
      mode_of_transport: mot,
      direction: 'export',
      tenant_id: user.tenant_id
    )
    origin_addons = !counterpart_origin_addons.empty? ? counterpart_origin_addons : origin_hub.addons.where(
      cargo_class: cargo_class,
      counterpart_hub_id: nil,
      tenant_vehicle_id: tenant_vehicle_id,
      mode_of_transport: mot,
      direction: 'export',
      tenant_id: user.tenant_id
    )
    if origin_addons.empty?
      origin_addons = origin_hub.addons.where(
        cargo_class: cargo_class,
        counterpart_hub_id: nil,
        mode_of_transport: mot,
        direction: 'export',
        tenant_id: user.tenant_id
      )
    end
    counterpart_destination_addons = destination_hub.addons.where(
      cargo_class: cargo_class,
      counterpart_hub_id: origin_hub.id,
      tenant_vehicle_id: tenant_vehicle_id,
      mode_of_transport: mot,
      direction: 'import',
      tenant_id: user.tenant_id
    )
    destination_addons = !counterpart_destination_addons.empty? ? counterpart_destination_addons : destination_hub.addons.where(
      cargo_class: cargo_class,
      counterpart_hub_id: nil,
      tenant_vehicle_id: tenant_vehicle_id,
      mode_of_transport: mot,
      direction: 'import',
      tenant_id: user.tenant_id
    )
    if destination_addons.empty?
      destination_addons = destination_hub.addons.where(
        cargo_class: cargo_class,
        counterpart_hub_id: nil,
        mode_of_transport: mot,
        direction: 'import',
        tenant_id: user.tenant_id
      )
    end

    { destination: destination_addons, origin: origin_addons }
  end

  def self.condense_addons(addons, cargos, user, mot)
    condensed_addons = []
    pricing_tools = OfferCalculator::PricingTools.new(shipment: cargos.first.shipment, user: user)
    addons[:origin].each do |oao|
      matching_ao = addons[:destination].select { |dao| dao.addon_type === oao.addon_type }

      new_ao = oao.dup.as_json
      if !matching_ao.empty?
        new_ao.delete(:fees)
        new_ao[:export] = pricing_tools.calc_addon_charges(oao[:fees], cargos, user, mot)
        new_ao[:import] = pricing_tools.calc_addon_charges(matching_ao.first[:fees], cargos, user, mot)

        new_ao[:flag] = 'ambidirectional'
        condensed_addons << new_ao
      else
        new_ao[:flag] = 'unidirectional'
        new_ao[:fees] = pricing_tools.calc_addon_charges(oao.fees, cargos, user, mot)
        condensed_addons << new_ao
      end
    end
    hash_addons = {}
    condensed_addons.each do |ca|
      hash_addons[ca['addon_type']] = ca
    end
    hash_addons
  end
end

# == Schema Information
#
# Table name: addons
#
#  id                   :bigint           not null, primary key
#  title                :string
#  text                 :jsonb            is an Array
#  tenant_id            :integer
#  read_more            :string
#  accept_text          :string
#  decline_text         :string
#  additional_info_text :string
#  cargo_class          :string
#  hub_id               :integer
#  counterpart_hub_id   :integer
#  mode_of_transport    :string
#  tenant_vehicle_id    :integer
#  direction            :string
#  addon_type           :string
#  fees                 :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
