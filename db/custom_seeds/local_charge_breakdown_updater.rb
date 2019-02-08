Tenant.find_each do |tenant|
# Tenant.where(subdomain: 'gateway').each do |tenant|
  next if tenant.subdomain == 'gateway'
  shipment_association = tenant.quotation_tool? ? tenant.shipments.where.not(quotation_id: nil) : tenant.shipments
  shipment_association.each do |shipment|
    shipment.charge_breakdowns.each do |charge_breakdown|
      export = charge_breakdown.charge('export')
      next if export.nil?

      children_charge_category = ChargeCategory.find_or_create_by(
        name: shipment.fcl? ? 'Container' : 'Cargo Item',
        code: shipment.fcl? ? 'container' : 'cargo_item',
        cargo_unit_id: shipment.fcl? ? 'container' : 'cargo_item'
      )
      parent_charge = Charge.create(
        children_charge_category: children_charge_category,
        charge_category: export.children_charge_category,
        charge_breakdown: charge_breakdown,
        parent: export,
        price: export.price
      )

      Charge.where(parent_id: export.id).each do |charge|
        next if charge == parent_charge
        if !charge.children.empty?
          charge.children.each do |cc|
            cc.detail_level += 1
            cc.save!
          end
        end
        charge.parent = parent_charge
        charge.detail_level += 1
        charge.save!
      end
    end
  end
end