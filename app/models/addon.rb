# frozen_string_literal: true

class Addon < Legacy::Addon
  belongs_to :hub

  def self.prepare_addons(origin_hub, destination_hub, cargo_class, tenant_vehicle_id, mot, cargos, user)
    addons = determine_addons(origin_hub, destination_hub, cargo_class, tenant_vehicle_id, mot, user)
    condense_addons(addons, cargos, user, mot)
  end

  def self.determine_addons(origin_hub, destination_hub, cargo_class, tenant_vehicle_id, mot, user)
    counterpart_origin_addons = origin_hub.addons.where(
      cargo_class: cargo_class,
      counterpart_hub_id: destination_hub.id,
      tenant_vehicle_id: tenant_vehicle_id,
      mode_of_transport: mot,
      direction: "export",
      organization_id: user.organization_id
    )
    origin_addons = !counterpart_origin_addons.empty? ? counterpart_origin_addons : origin_hub.addons.where(
      cargo_class: cargo_class,
      counterpart_hub_id: nil,
      tenant_vehicle_id: tenant_vehicle_id,
      mode_of_transport: mot,
      direction: "export",
      organization_id: user.organization_id
    )
    if origin_addons.empty?
      origin_addons = origin_hub.addons.where(
        cargo_class: cargo_class,
        counterpart_hub_id: nil,
        mode_of_transport: mot,
        direction: "export",
        organization_id: user.organization_id
      )
    end
    counterpart_destination_addons = destination_hub.addons.where(
      cargo_class: cargo_class,
      counterpart_hub_id: origin_hub.id,
      tenant_vehicle_id: tenant_vehicle_id,
      mode_of_transport: mot,
      direction: "import",
      organization_id: user.organization_id
    )
    destination_addons = if !counterpart_destination_addons.empty?
      counterpart_destination_addons
    else
      destination_hub.addons.where(
        cargo_class: cargo_class,
        counterpart_hub_id: nil,
        tenant_vehicle_id: tenant_vehicle_id,
        mode_of_transport: mot,
        direction: "import",
        organization_id: user.organization_id
      )
    end
    if destination_addons.empty?
      destination_addons = destination_hub.addons.where(
        cargo_class: cargo_class,
        counterpart_hub_id: nil,
        mode_of_transport: mot,
        direction: "import",
        organization_id: user.organization_id
      )
    end

    {destination: destination_addons, origin: origin_addons}
  end

  def self.condense_addons(addons, cargos, user, mot)
    condensed_addons = []
    shipment = cargos.first.shipment
    pricing_tools = OfferCalculator::PricingTools.new(shipment: shipment, user: user)
    addons[:origin].each do |oao|
      matching_ao = addons[:destination].select { |dao| dao.addon_type === oao.addon_type }

      new_ao = oao.dup.as_json
      if !matching_ao.empty?
        new_ao.delete(:fees)
        new_ao[:export] = pricing_tools.calc_addon_charges(oao[:fees], cargos, user, mot)
        new_ao[:import] = pricing_tools.calc_addon_charges(matching_ao.first[:fees], cargos, user, mot)

        new_ao[:flag] = "ambidirectional"
      else
        new_ao[:flag] = "unidirectional"
        new_ao[:fees] = pricing_tools.calc_addon_charges(oao.fees, cargos, user, mot)
      end
      condensed_addons << new_ao
    end
    hash_addons = {}
    condensed_addons.each do |ca|
      hash_addons[ca["addon_type"]] = ca
    end
    hash_addons
  end
end

# == Schema Information
#
# Table name: addons
#
#  id                   :bigint           not null, primary key
#  accept_text          :string
#  additional_info_text :string
#  addon_type           :string
#  cargo_class          :string
#  decline_text         :string
#  direction            :string
#  fees                 :jsonb
#  mode_of_transport    :string
#  read_more            :string
#  text                 :jsonb            is an Array
#  title                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  counterpart_hub_id   :integer
#  hub_id               :integer
#  organization_id      :uuid
#  tenant_id            :integer
#  tenant_vehicle_id    :integer
#
# Indexes
#
#  index_addons_on_organization_id  (organization_id)
#  index_addons_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
