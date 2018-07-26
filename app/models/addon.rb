class Addon < ApplicationRecord
  belongs_to :hub

  include PricingTools
  extend PricingTools

  def self.prepare_addons(origin_hub, destination_hub, cargo_class, tenant_vehicle_id, mot, cargos, user)
    addons = determine_addons(origin_hub, destination_hub, cargo_class, tenant_vehicle_id, mot)
    condensed_addons = condense_addons(addons, cargos, user, mot)
  end
  private
  def self.determine_addons(origin_hub, destination_hub, cargo_class, tenant_vehicle_id, mot)
    counterpart_origin_addons = origin_hub.addons.where(
      cargo_class: cargo_class,
      counterpart_hub_id: destination_hub.id,
      tenant_vehicle_id: tenant_vehicle_id,
      mode_of_transport: mot,
      direction: 'export'
    )
    origin_addons = !counterpart_origin_addons.empty? ? counterpart_origin_addons : origin_hub.addons.where(
      cargo_class: cargo_class,
      counterpart_hub_id: nil,
      tenant_vehicle_id: tenant_vehicle_id,
      mode_of_transport: mot,
      direction: 'export'
    )
    counterpart_destination_addons = destination_hub.addons.where(
      cargo_class: cargo_class,
      counterpart_hub_id: origin_hub.id,
      tenant_vehicle_id: tenant_vehicle_id,
      mode_of_transport: mot,
      direction: 'import'
    )
    destination_addons = !counterpart_destination_addons.empty? ? counterpart_destination_addons : destination_hub.addons.where(
      cargo_class: cargo_class,
      counterpart_hub_id: nil,
      tenant_vehicle_id: tenant_vehicle_id,
      mode_of_transport: mot,
      direction: 'import'
    )
    return {destination: destination_addons, origin: origin_addons}
    
  end

  def self.condense_addons(addons, cargos, user, mot)
    condensed_addons = []
    addons[:origin].each do |oao|
      matching_ao = addons[:destination].select{|dao| dao.addon_type === oao.addon_type}

      new_ao = oao.dup().as_json
      if !matching_ao.empty?
        new_ao.delete(:fees)
        new_ao[:export] = calc_addon_charges(oao[:fees], cargos, user, mot)
        new_ao[:import] = calc_addon_charges(matching_ao.first[:fees], cargos, user, mot)
        
        new_ao[:flag] = 'ambidirectional'
        condensed_addons << new_ao
      else
        new_ao[:flag] = 'unidirectional'
        new_ao[:fees] = calc_addon_charges(oao.fees, cargos, user, mot)
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
