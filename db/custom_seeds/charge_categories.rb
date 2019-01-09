%w(trucking_pre trucking_on).each do |code| 
  ChargeCategory.where(code: [code, code.upcase], tenant_id: nil).each do |charge_category|
    new_name = charge_category.name.sub('Trucking ', '').strip
    charge_category.name = new_name
    charge_category.save!
  end
end
%w(trucking_lcl trucking_fcl_20 trucking_fcl_40 trucking_fcl_40_hq).each do |code| 
  ChargeCategory.where(code: [code, code.upcase], tenant_id: nil).each do |charge_category|
    new_name = charge_category.name.sub('Trucking ', '').strip
    charge_category.name = new_name
    charge_category.save!
  end
end

ChargeCategory.where(code: ['cargo', 'CARGO'], tenant_id: nil).each do |charge_category|
  charge_category.name = 'Freight'
  charge_category.save!
end

ChargeCategory.where(code: ['import', 'IMPORT'], tenant_id: nil).each do |charge_category|
  charge_category.name = 'Destination Local Charges'
  charge_category.save!
end

ChargeCategory.where(code: ['export', 'EXPORT'], tenant_id: nil).each do |charge_category|
  charge_category.name = 'Origin Local Charges'
  charge_category.save!
end