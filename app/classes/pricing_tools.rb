module PricingTools
  include MongoTools
  include CurrencyTools

  def get_mongo_client 
    client = get_client
    return client
  end
  def get_user_price(client, path_key, user)
    path_pricing = get_item_fn(client, 'itineraryPricings', '_id', path_key)
    Rails.logger.info "PATH KEY FOR PRICING #{path_key}"
    return nil if path_pricing.nil? 

    path_pricing_key = path_pricing[user.id.to_s] ? user.id.to_s : "open"
    price_key        = path_pricing[path_pricing_key]    

    get_item_fn(client, 'pricings', '_id', price_key)
  end
  def determine_local_charges(hub, load_type, cargos, direction, mot, user)
    cargo = load_type === 'container' ? {
      number_of_items: cargos.length,
      weight: cargos.map { |cargo| cargo.payload_in_kg }.sum.to_f
    } : {
      number_of_items: cargos.length,
      volume: cargos.map { |cargo| cargo.volume }.sum.to_f,
      weight: cargos.map { |cargo| cargo.payload_in_kg }.sum.to_f
    }
    lt = load_type == 'cargo_item' ? 'lcl' : cargos[0].size_class
    query = [
      {"tenant_id" => hub.tenant_id},
      {"hub_id" => hub.id},
      {"load_type" => lt},
      {"mode_of_transport" => mot}
    ]
    charge = get_items_query('localCharges', query).first
    return {} if charge.nil?
    totals = {"total" => {}}
    charge[direction].each do |k,v|
      case v["rate_basis"]
      when "PER_ITEM"
        totals[k] ? totals[k]["value"] += v["rate"].to_i : totals[k] = {"value" => v["rate"].to_i, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_CBM"
        totals[k] ? totals[k]["value"] += v["rate"].to_i * cargo.volume : totals[k] = {"value" => v["rate"].to_i * cargo[:volume], "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_CBM_TON"
        ton = (cargo[:weight] / 1000) * v["ton"]
        cbm = cargo[:volume] * v["cbm"]
        tmp = 0
        cbm > ton ? tmp = cbm : tmp = ton
        tmp > v["min"] ? res = tmp : res = v["min"]
        totals[k] ? totals[k]["value"] += res : totals[k] = {"value" => res, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_SHIPMENT"
        totals[k] ? totals[k]["value"] += v["rate"].to_i : totals[k] = {"value" => v["rate"].to_i, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      end
    end
    converted = sum_and_convert_cargo(totals, user.currency)
    totals["total"] = {value: converted, currency: user.currency}
    return totals
  end

  def calc_customs_fees(charge, cargos, load_type, user)
    cargo = load_type === 'container' ? {
      number_of_items: cargos.length,
      weight: cargos.map { |cargo| cargo.payload_in_kg }.sum.to_f
    } : {
      number_of_items: cargos.length,
      volume: cargos.map { |cargo| cargo.volume }.sum.to_f,
      weight: cargos.map { |cargo| cargo.payload_in_kg }.sum.to_f
    }
    
    return {} if charge.nil?
    totals = {"total" => {}}
    charge.each do |k,v|
      case v["rate_basis"]
      when "PER_ITEM"
        totals[k] ? totals[k]["value"] += v["value"].to_i : totals[k] = {"value" => v["value"].to_i, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_CBM"
        totals[k] ? totals[k]["value"] += v["value"].to_i * cargo.volume : totals[k] = {"value" => v["value"].to_i * cargo[:volume], "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_CBM_TON"
        ton = (cargo[:weight] / 1000) * v["ton"]
        cbm = cargo[:volume] * v["cbm"]
        tmp = 0
        cbm > ton ? tmp = cbm : tmp = ton
        tmp > v["min"] ? res = tmp : res = v["min"]
        totals[k] ? totals[k]["value"] += res : totals[k] = {"value" => res, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_SHIPMENT"
        totals[k] ? totals[k]["value"] += v["value"].to_i : totals[k] = {"value" => v["value"].to_i, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      end
    end
    
    converted = sum_and_convert_cargo(totals, user.currency)
    totals["total"] = {value: converted, currency: user.currency}
    return totals
  end

  def determine_cargo_item_price(client, cargo, pathKey, user, quantity)
    pricing = get_user_price(client, pathKey, user)
    return nil if pricing.nil?
    totals = {"total" => {}}
    pricing["data"].each do |k, v|
      case v["rate_basis"]
      when "PER_ITEM"
        totals[k] ? totals[k]["value"] += v["rate"].to_i : totals[k] = {"value" => v["rate"].to_i, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_CBM"
        totals[k] ? totals[k]["value"] += v["rate"].to_i * cargo.volume : totals[k] = {"value" => v["rate"].to_i * cargo.volume, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_CBM_TON"
        ton = cargo.payload_in_tons * v["ton"]
        cbm = cargo.volume * v["cbm"]
        tmp = 0
        cbm > ton ? tmp = cbm : tmp = ton
        tmp > v["min"] ? res = tmp : res = v["min"]
        totals[k] ? totals[k]["value"] += res : totals[k] = {"value" => res, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      when "PER_SHIPMENT"
        totals[k] ? totals[k]["value"] += v["rate"].to_i / quantity : totals[k] = {"value" => v["rate"].to_i / quantity, "currency" => v["currency"]}
        if !totals[k]["currency"]
          totals[k]["currency"] = v["currency"]
        end
      end
      
    converted = sum_and_convert_cargo(totals, user.currency)
    cargo.unit_price = {value: converted, currency: user.currency}
    totals["total"] = {value: converted * cargo.quantity, currency: user.currency}
    
    return totals
  end
end

  def determine_container_price(client, container, pathKey, user, quantity)
    pricing = get_user_price(client, pathKey, user)
    return nil if pricing.nil?
    totals = {"total" => {}}
    
    pricing["data"].each do |k, v|
      # if v["rate_basis"].include?('CONTAINER')
      #   totals[k] ? totals[k]["value"] += v["rate"].to_i : totals[k] = {"value" => v["rate"].to_i, "currency" => v["currency"]}
      #   if !totals[k]["currency"]
      #     totals[k]["currency"] = v["currency"]
      #   end
      #   # totals[v["currency"]] ? totals[v["currency"]] += v["rate"].to_i : totals[v["currency"]] = v["rate"].to_i 
      # end
      case v["rate_basis"]
        when 'PER_CONTAINER'
          totals[k] ? totals[k]["value"] += v["rate"].to_i : totals[k] = {"value" => v["rate"].to_i, "currency" => v["currency"]}
          if !totals[k]["currency"]
            totals[k]["currency"] = v["currency"]
          end
        when "PER_ITEM"
          totals[k] ? totals[k]["value"] += v["rate"].to_i : totals[k] = {"value" => v["rate"].to_i, "currency" => v["currency"]}
          if !totals[k]["currency"]
            totals[k]["currency"] = v["currency"]
          end
        when "PER_SHIPMENT"
          totals[k] ? totals[k]["value"] += v["rate"].to_i / quantity : totals[k] = {"value" => v["rate"].to_i / quantity, "currency" => v["currency"]}
          if !totals[k]["currency"]
            totals[k]["currency"] = v["currency"]
          end
      end
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
    resp = get_items('pricings', 'tenant_id', tenant_id).to_a
    result = {}
    resp.each do |pr|
      result[pr["_id"]] = pr
    end
    return result
  end

  def get_route_pricings_array(route_id, tenant_id)
    client = get_client
    query = [{'tenant_id' => {"$eq" => tenant_id}}, {"route" => {"$eq" => route_id.to_i}}]
    resp = get_items_query_fn(client, 'pricings', query).to_a
    return resp
  end

  def get_itinerary_pricings_array(itinerary_id, tenant_id)
    client = get_client
    query = [{'tenant_id' => {"$eq" => tenant_id}}, {"itinerary" => {"$eq" => itinerary_id.to_i}}]
    resp = get_items_query_fn(client, 'pricings', query).to_a
    return resp
  end

  def get_user_pricings(user_id)
    resp = get_items('userPricings', '_id', "#{user_id}")
    return resp.first
  end

  def get_dedicated_hash(user_id, tenant_id)
    query = [{'tenant_id' => {"$eq" => tenant_id}}, {"#{user_id}" => {"$exists" => true}}]
    resp = get_items_query('hubRoutePricings', query).to_a
    result = {}
    resp.each do |pr|
      result["#{pr["route"]}"] = true
    end
    return result
  end

  def get_tenant_path_pricings(tenant_id)
    resp = get_items('hubRoutePricings', 'tenant_id', tenant_id)
    return resp.to_a
  end

  def get_hub_route_pricings(hub_route_id)
    resp = get_items('hubRoutePricings', 'hub_route_id', hub_route_id)
    return resp.to_a
  end

  def get_itinerary_pricings(itinerary_id)
    resp = get_items('itineraryPricings', 'itinerary_id', itinerary_id)
    return resp.to_a
  end

  def get_route_pricings(route_id)
    resp = get_items('hubRoutePricings', 'route_id', route_id)
    return resp.to_a
  end

  def update_pricing(id, data)
    resp = update_item('pricings', {_id: id }, data)
    return resp
  end

  def get_itinerary_pricings_hash(itinerary_id)
    resp = get_items('itineraryPricings', 'itinerary_id', itinerary_id).to_a
    result = {}
    resp.each do |pr|
      result[pr["_id"]] = pr
    end
    return result
  end

  def get_hub_route_user_pricings(hub_route_id, user_id)
    query = [{'hub_route' => {"$eq" => hub_route_id}}, {"#{user_id}" => {"$exists" => true}}]
    resp = get_items_query('hubRoutePricings', query)
    return resp.to_a
  end

  def update_hub_route_pricing(key, data)
    update_item('hubRoutePricings', {_id: key }, data)
  end

  def update_itinerary_pricing(key, data)
    update_item('itineraryPricings', {_id: key }, data)
  end
end


