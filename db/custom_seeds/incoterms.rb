# frozen_string_literal: true

puts 'Destroying Incoterms...'
IncotermScope.destroy_all
IncotermCharge.destroy_all
IncotermLiability.destroy_all
Incoterm.destroy_all

puts 'Seeding Incoterms...'

incoterms = [
  {
    code: 'EXW',
    description: 'Ex-Works',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Buyer',
    pre_carriage: 'Buyer',
    origin_customs: 'Buyer',
    origin_port_charges: 'Buyer',
    forwarders_fee: 'Buyer',
    origin_vessel_loading: 'Buyer',
    freight: 'Buyer',
    destination_port_charges: 'Buyer',
    destination_customs: 'Buyer',
    on_carriage: 'Buyer',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'FCA',
    description: 'Free Carrier',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: 'Buyer',
    origin_port_charges: 'Buyer',
    forwarders_fee: 'Buyer',
    origin_vessel_loading: 'Buyer',
    freight: 'Buyer',
    destination_port_charges: 'Buyer',
    destination_customs: 'Buyer',
    on_carriage: 'Buyer',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },

  {
    code: 'FAS',
    description: 'Free Alongside Ship',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: 'Seller',
    origin_port_charges: 'Seller',
    forwarders_fee: 'Seller',
    origin_vessel_loading: 'Buyer',
    freight: 'Buyer',
    destination_port_charges: 'Buyer',
    destination_customs: 'Buyer',
    on_carriage: 'Buyer',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'FOB',
    description: 'Free On-Board Vessel',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: 'Seller',
    origin_port_charges: 'Seller',
    forwarders_fee: 'Seller',
    origin_vessel_loading: 'Seller',
    freight: 'Buyer',
    destination_port_charges: 'Buyer',
    destination_customs: 'Buyer',
    on_carriage: 'Buyer',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'CFR',
    description: 'Cost & Freight',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: 'Seller',
    origin_port_charges: 'Seller',
    forwarders_fee: 'Seller',
    origin_vessel_loading: 'Seller',
    freight: { risk: 'Buyer', charge: 'Seller' },
    destination_port_charges: 'Buyer',
    destination_customs: 'Buyer',
    on_carriage: 'Buyer',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'CIF',
    description: 'Cost Insurance & Freight',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: 'Seller',
    origin_port_charges: 'Seller',
    forwarders_fee: 'Seller',
    origin_vessel_loading: 'Seller',
    freight: { risk: 'Buyer', charge: 'Seller' },
    destination_port_charges: 'Buyer',
    destination_customs: 'Buyer',
    on_carriage: 'Buyer',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'CPT',
    description: 'Carriage Paid to',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: { risk: 'Buyer', charge: 'Seller' },
    origin_port_charges: { risk: 'Buyer', charge: 'Seller' },
    forwarders_fee: 'Seller',
    origin_vessel_loading: { risk: 'Buyer', charge: 'Seller' },
    freight: { risk: 'Buyer', charge: 'Seller' },
    destination_port_charges: { risk: 'Buyer', charge: 'Seller' },
    destination_customs: 'Buyer',
    on_carriage: { risk: 'Buyer', charge: 'Seller' },
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'CIP',
    description: 'Carriage & Insurance Paid To',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: { risk: 'Buyer', charge: 'Seller' },
    origin_port_charges: { risk: 'Buyer', charge: 'Seller' },
    forwarders_fee: { risk: 'Buyer', charge: 'Seller' },
    origin_vessel_loading: { risk: 'Buyer', charge: 'Seller' },
    freight: { risk: 'Buyer', charge: 'Seller' },
    destination_port_charges: { risk: 'Buyer', charge: 'Seller' },
    destination_customs: 'Buyer',
    on_carriage: { risk: 'Buyer', charge: 'Seller' },
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'DAF',
    description: 'Delivery At Frontier',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: 'Seller',
    origin_port_charges: 'Seller',
    forwarders_fee: 'Seller',
    origin_vessel_loading: 'Seller',
    freight: 'Seller',
    destination_port_charges: 'Seller',
    destination_customs: 'Buyer',
    on_carriage: 'Buyer',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'DES',
    description: 'Delivered Ex-Ship',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: 'Seller',
    origin_port_charges: 'Seller',
    forwarders_fee: 'Seller',
    origin_vessel_loading: 'Seller',
    freight: 'Seller',
    destination_port_charges: 'Buyer',
    destination_customs: 'Buyer',
    on_carriage: 'Buyer',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'DAP',
    description: 'Delivered at Place',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: 'Seller',
    origin_port_charges: 'Seller',
    forwarders_fee: 'Seller',
    origin_vessel_loading: 'Seller',
    freight: 'Seller',
    destination_port_charges: 'Buyer',
    destination_customs: 'Buyer',
    on_carriage: 'Buyer',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'DEQ',
    description: 'Delivered Ex-Quay, Duty Unpaid',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: 'Seller',
    origin_port_charges: 'Seller',
    forwarders_fee: 'Seller',
    origin_vessel_loading: 'Seller',
    freight: 'Seller',
    destination_port_charges: 'Seller',
    destination_customs: 'Buyer',
    on_carriage: 'Buyer',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'DDU',
    description: 'Delivered Duty Unpaid',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: 'Seller',
    origin_port_charges: 'Seller',
    forwarders_fee: 'Seller',
    origin_vessel_loading: 'Seller',
    freight: 'Seller',
    destination_port_charges: 'Seller',
    destination_customs: 'Buyer',
    on_carriage: 'Seller',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  },
  {
    code: 'DDP',
    description: 'Delivered Duty Paid',
    origin_warehousing: 'Seller',
    origin_labour: 'Seller',
    origin_packing: 'Seller',
    origin_loading: 'Seller',
    pre_carriage: 'Seller',
    origin_port_charges: 'Seller',
    forwarders_fee: 'Seller',
    origin_vessel_loading: 'Seller',
    freight: 'Seller',
    destination_port_charges: 'Seller',
    destination_customs: 'Seller',
    on_carriage: 'Seller',
    destination_loading: 'Buyer',
    destination_labour: 'Buyer',
    destination_warehousing: 'Buyer'
  }
]
incoterm_details = {}
liability_hash = {}
charge_hash = {}
scope_hash = {}
incoterms.each do |incoterm_hash|
  incoterm_key = incoterm_hash[:code]
  incoterm_details[incoterm_hash[:code]] = {
    description: incoterm_hash[:description],
    code: incoterm_hash[:code]
  }
  incoterm_hash.delete(:description)
  incoterm_hash.delete(:code)
  liability_hash[incoterm_key] = {
    buyer: {},
    seller: {}
  }
  charge_hash[incoterm_key] = {
    buyer: {},
    seller: {}
  }
  scope_hash[incoterm_key] = {
    buyer: {},
    seller: {}
  }
  incoterm_hash.each do |key, value|
    if value.is_a?(Hash)
      if value[:risk] == 'Buyer'
        liability_hash[incoterm_key][:buyer][key] = true
        liability_hash[incoterm_key][:seller][key] = false
      else
        liability_hash[incoterm_key][:buyer][key] = false
        liability_hash[incoterm_key][:seller][key] = true
      end
      if value[:charge] == 'Buyer'
        charge_hash[incoterm_key][:buyer][key] = true
        charge_hash[incoterm_key][:seller][key] = false
        if key == :pre_carriage || key == :on_carriage
          scope_hash[incoterm_key][:buyer][key] = true
          scope_hash[incoterm_key][:seller][key] = false
        end
      else
        charge_hash[incoterm_key][:buyer][key] = false
        charge_hash[incoterm_key][:seller][key] = true
        if key == :pre_carriage || key == :on_carriage
          scope_hash[incoterm_key][:buyer][key] = false
          scope_hash[incoterm_key][:seller][key] = true
        end
      end

    else
      if value == 'Buyer'
        liability_hash[incoterm_key][:buyer][key] = true
        charge_hash[incoterm_key][:buyer][key] = true

        liability_hash[incoterm_key][:seller][key] = false
        charge_hash[incoterm_key][:seller][key] = false
        if key == :pre_carriage || key == :on_carriage
          scope_hash[incoterm_key][:buyer][key] = true
          scope_hash[incoterm_key][:seller][key] = false
        end
      else
        liability_hash[incoterm_key][:seller][key] = true
        charge_hash[incoterm_key][:seller][key] = true

        liability_hash[incoterm_key][:buyer][key] = false
        charge_hash[incoterm_key][:buyer][key] = false
        if key == :pre_carriage || key == :on_carriage
          scope_hash[incoterm_key][:buyer][key] = false
          scope_hash[incoterm_key][:seller][key] = true
        end
      end
    end
  end
  seller_liability = IncotermLiability.find_or_create_by!(liability_hash[incoterm_key][:seller])
  buyer_liability = IncotermLiability.find_or_create_by!(liability_hash[incoterm_key][:buyer])

  seller_charge = IncotermCharge.find_or_create_by!(charge_hash[incoterm_key][:seller])
  buyer_charge = IncotermCharge.find_or_create_by!(charge_hash[incoterm_key][:buyer])

  seller_scope = IncotermScope.find_or_create_by!(scope_hash[incoterm_key][:seller])
  buyer_scope = IncotermScope.find_or_create_by!(scope_hash[incoterm_key][:buyer])

  incoterm_details[incoterm_key][:seller_incoterm_scope_id] = seller_scope.id
  incoterm_details[incoterm_key][:buyer_incoterm_scope_id] = buyer_scope.id

  incoterm_details[incoterm_key][:seller_incoterm_charge_id] = seller_charge.id
  incoterm_details[incoterm_key][:buyer_incoterm_charge_id] = buyer_charge.id

  incoterm_details[incoterm_key][:seller_incoterm_liability_id] = seller_liability.id
  incoterm_details[incoterm_key][:buyer_incoterm_liability_id] = buyer_liability.id
  Incoterm.find_or_create_by!(incoterm_details[incoterm_key])
end
