module PricingTools # TODO: mongo
  include MongoTools
  include CurrencyTools

  def get_mongo_client 
    get_client
  end

  def get_user_price(client, path_key, user, shipment_date)
    path_pricing = get_item_fn(client, 'itineraryPricings', '_id', path_key)
    Rails.logger.debug "PATH KEY FOR PRICING #{path_key}"
    return nil if path_pricing.nil? 

    path_pricing_key = path_pricing[user.id.to_s] ? user.id.to_s : "open"
    price_key        = path_pricing[path_pricing_key]    

    pricing = get_item_fn(client, 'pricings', '_id', price_key)
    
    final_pricing = pricing
    if pricing["exceptions"] && pricing["exceptions"].length > 0
      pricing["exceptions"].each do |ex|
        if ex["effective_date"] <= shipment_date && ex["expiration_date"] >= shipment_date
          final_pricing = ex
        end
      end
    end
    return final_pricing
  end
  
  def determine_local_charges(hub, load_type, cargos, direction, mot, user)
    cargo_hash = cargos.each_with_object(Hash.new(0)) do |cargo_unit, return_h|
      return_h[:number_of_items] += cargo_unit.quantity unless cargo_unit.try(:quantity).nil?
      return_h[:volume]          += cargo_unit.volume   unless cargo_unit.volume.nil?
      
      return_h[:weight]          += (cargo_unit.try(:weight) || cargo_unit.payload_in_kg)
    end

    lt = load_type == 'cargo_item' ? 'lcl' : cargos[0].size_class
    charge = hub.local_charges.find_by(load_type: lt, mode_of_transport: mot)
    return {} if charge.nil?
    totals = {"total" => {}}
    charge[direction].each do |k, fee|
      totals[k]             ||= { "value" => 0, "currency" => fee["currency"] }
      totals[k]["currency"] ||= fee["currency"] 

      totals[k]["value"] += fee_value(fee, cargo_hash) 
    end
    converted = sum_and_convert_cargo(totals, user.currency)
    totals["total"] = { value: converted, currency: user.currency}
    return totals
  end

  def calc_customs_fees(charge, cargos, load_type, user)
    cargo_hash = cargos.each_with_object(Hash.new(0)) do |cargo_unit, return_h|
      return_h[:number_of_items] += cargo_unit.quantity unless cargo_unit.quantity.nil?
      return_h[:volume]          += cargo_unit.try(:volume) || 0
      return_h[:weight]          += (cargo_unit.try(:weight) || cargo_unit.payload_in_kg)
    end

    return {} if charge.nil?
    totals = {"total" => {}}
    charge.each do |k, fee|
      totals[k]             ||= { "value" => 0, "currency" => fee["currency"] }
      totals[k]["currency"] ||= fee["currency"] 

      totals[k]["value"] += fee_value(fee, cargo_hash) 
    end
    
    converted = sum_and_convert_cargo(totals, user.currency)
    totals["total"] = {value: converted, currency: user.currency}
    return totals
  end

  def determine_cargo_item_price(client, cargo, pathKey, user, quantity, shipment_date)
    pricing = get_user_price(client, pathKey, user, shipment_date)
    return nil if pricing.nil?
    totals = { "total" => {} }
    
    pricing["data"].keys.each do |k|
      fee = pricing["data"][k].clone

      totals[k]             ||= { "value" => 0, "currency" => fee["currency"] }
      totals[k]["currency"] ||= fee["currency"] 
      
      if fee["hw_rate_basis"]
        totals[k]["value"] += heavy_weight_fee_value(fee, cargo)
      else
        
        totals[k]["value"] += fee_value(fee, get_cargo_hash(cargo))["value"]
      end
    end
    
    converted = sum_and_convert_cargo(totals, user.currency)
    cargo.try(:unit_price=, { value: converted, currency: user.currency })
    totals["total"]  = { value: converted, currency: user.currency }
    
    return totals
  end

  def determine_container_price(client, container, pathKey, user, quantity, shipment_date)
    pricing = get_user_price(client, pathKey, user, shipment_date)
    return nil if pricing.nil?
    totals = {"total" => {}}
    
    pricing["data"].each do |k, fee|
      totals[k]             ||= { "value" => 0, "currency" => fee["currency"] }
      totals[k]["currency"] ||= fee["currency"] 

      totals[k]["value"] += fee_value(fee, get_cargo_hash(container))
    end

    cargo_rate_value = sum_and_convert_cargo(totals, user.currency)
    return nil if cargo_rate_value.nil? || cargo_rate_value == 0
    container.unit_price = {value: cargo_rate_value, currency: user.currency}
    totals["total"] = {value: cargo_rate_value * container.quantity, currency: user.currency}
    return totals
  end

  def get_tenant_pricings(tenant_id)
    resp = get_items('pricings', 'tenant_id', tenant_id)
    return resp.to_a
  end

  def get_tenant_pricings_hash(tenant_id)
    pricings = get_items('pricings', 'tenant_id', tenant_id).to_a
    pricings.each_with_object({}) do |pricing, return_h|
      return_h[pricing["_id"]] = pricing
    end
  end

  def get_route_pricings_array(route_id, tenant_id)
    client = get_client
    query = [{'tenant_id' => {"$eq" => tenant_id}}, {"route" => {"$eq" => route_id.to_i}}]
    get_items_query_fn(client, 'pricings', query).to_a
  end

  def get_itinerary_pricings_array(itinerary_id, tenant_id)
    client = get_client
    query = [{'tenant_id' => {"$eq" => tenant_id}}, {"itinerary" => {"$eq" => itinerary_id.to_i}}]
    get_items_query_fn(client, 'pricings', query).to_a
  end

  def get_user_pricings(id)
    User.find(id: id).pricings.each_with_object({}) do |pricing, return_h|
      return_h[pricing.route.name] = true # TODO: no route model
    end

    # resp = get_items('userPricings', '_id', "#{user_id}").first
  end

  def get_dedicated_hash(user_id, tenant_id)
    HubRoutePricing.where(tenant_id: tenant_id, user_id: user_id).each_with_object({}) do |pricing, return_h|
      return_h[pricing.route.name] = true # TODO: no route model
    end
    # query = [{'tenant_id' => {"$eq" => tenant_id}}, {"#{user_id}" => {"$exists" => true}}]
    # pricings = get_items_query('hubRoutePricings', query).to_a
    # pricings.each_with_object({}) do |pricing, return_h|
    #   return_h[pricing["route"].to_s] = true
    # end
  end

  def get_tenant_path_pricings(tenant_id)
    HubRoutePricing.where(tenant_id: tenant_id)
    # get_items('hubRoutePricings', 'tenant_id', tenant_id).to_a
  end

  def get_hub_route_pricings(hub_route_id)
    HubRoutePricing.where(hub_route_id: hub_route_id)
    # get_items('hubRoutePricings', 'hub_route_id', hub_route_id).to_a
  end

  def get_itinerary_pricings(itinerary_id)
    ItineraryPricing.where(itinerary_id: itinerary_id)
    # get_items('itineraryPricings', 'itinerary_id', itinerary_id).to_a
  end

  def get_route_pricings(route_id)
    HubRoutePricing.where(route_id: route_id)
    # get_items('hubRoutePricings', 'route_id', route_id).to_a
  end

  def update_pricing(id, data)
    Pricing.find(id).update(data)
    # update_item('pricings', {_id: id }, data)
  end

  # {"55_56_48"=>{"_id"=>"55_56_48", "open"=>"55_56_48_1_lcl", "itinerary_id"=>28, "tenant_id"=>1, "transport_category_id"=>48}}
  def get_itinerary_pricings_hash(itinerary_id)
    pricings = get_itinerary_pricings(itinerary_id)
    # pricings = get_items('itineraryPricings', 'itinerary_id', itinerary_id).to_a
    pricings.each_with_object({}) do |pricing, return_h|
      # return_h[pricing.id] = pricing.as_json # TODO: why _id like 1_2_16_1_lcl -> frontend
      pricing_key = "#{pricing.first_stop}_#{pricing.last_stop}_#{pricing.transport_category_id}"
      open = "#{pricing_key}_#{pricing.tenant_id}"
      return_h[pricing_key] = {id: pricing_key, open: open}
    end
  end

  def get_hub_route_user_pricings(hub_route_id, user_id)
    get_hub_route_pricings(hub_route_id).where(user_id: user_id)
    # query = [{'hub_route' => {"$eq" => hub_route_id}}, {"#{user_id}" => {"$exists" => true}}]
    # get_items_query('hubRoutePricings', query).to_a
  end

  # TODO: duplicated code
  def hub_route_pricing_update(id, data)
    HubRoutePricing.find(id).update(data)
    # update_item('hubRoutePricings', {_id: key }, data)
  end

  # TODO: duplicated code
  def itinerary_pricing_update(id, data)
    ItineraryPricing.find(id).update(data)
    # update_item('itineraryPricings', {_id: key }, data)
  end

  def pricing_delete(id)
    Pricing.destroy(id)
    # delete_item('pricings', _id: pricing_id)
  end

  def handle_range_fee(fee, cargo_hash)
    weight_kg = cargo_hash[:weight]
    case fee["rate_basis"]
    when 'PER_KG_RANGE'
      fee_range = fee["range"].find do |range|
        weight_kg >= range["min"] && weight_kg <= range["max"]
      end
      value = fee_range.nil? ? 0 : fee_range["rate"] * weight_kg
      return { "value" => value, "currency" => fee["currency"] }
    end

    nil
  end

  def heavy_weight_fee_value(fee, cargo)
    weight_kg = cargo.try(:weight) || cargo.try(:payload_in_kg)
    quantity  = cargo.try(:quantity) || 1
    cbm = cargo.volume
    ton = weight_kg / 1000
    
    if fee["hw_threshold"]
      ratio = weight_kg / cbm

      if ratio > fee["hw_threshold"]
        rate_value = [cbm, ton].max * quantity * fee["rate"].to_i
        return [rate_value, fee["min"]].max
      end

      return 0
    elsif fee["range"]
      fee_range = fee["range"].find do |range|
        weight_kg >= range["min"] && weight_kg <= range["max"]
      end

      return fee_range.nil? ? 0 : fee_range["rate"] * quantity
    end

    nil
  end

  def fee_value(fee, cargo_hash)
    awesome_print fee
    case fee["rate_basis"]
    when "PER_SHIPMENT", "PER_BILL"
      fee["value"].to_d
    when "PER_ITEM", "PER_CONTAINER"
      (fee["value"] || fee["rate"]).to_d * cargo_hash[:quantity]
    when "PER_CBM"
      fee["value"].to_d * cargo_hash[:volume]
    when "PER_CBM_TON"
      cbm = cargo_hash[:volume] * fee["cbm"]
      ton = (cargo_hash[:weight] / 1000) * fee["ton"]
      min = fee["min"] || 0

      [cbm, ton, min].max
    when "PER_TON"
      ton = (cargo_hash[:weight] / 1000) * fee["ton"]
      min = fee["min"] || 0

      [ton, min].max
    when "PER_WM"
      cbm = cargo_hash[:volume] * (fee["value"] || fee["rate"])
      ton = (cargo_hash[:weight] / 1000) * (fee["value"] || fee["rate"])
      min = fee["min"] || 0
      [cbm, ton, min].max 
    when /RANGE/
      handle_range_fee(fee, cargo_hash)
    end
  end

  def get_cargo_hash(cargo)
    {    
      volume: (cargo.try(:volume) || 1)  * (cargo.try(:quantity) || 1),
      weight: (cargo.try(:weight) || cargo.payload_in_kg) * (cargo.try(:quantity) || 1),
      quantity: cargo.try(:quantity) || 1  
    }
  end
end


