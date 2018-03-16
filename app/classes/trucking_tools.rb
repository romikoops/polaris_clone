module TruckingTools
 include MongoTools
  # Validations

  # Class methods
  def self.all_quotes
    # Has to be changed
    TruckingPricing.all
  end

  # Instance methods
  def trucker_info
    info = []
    info << "trucker_info deprecated..!"
  end

  def has_steptable?
    steptable != nil
  end

  def price_fcl(km, container_count)
    self.price_per_km * km * container_count
  end

  def price_lcl(km, cargo_item)
    self.price_per_km * km * 1 ########
  end

  def total_price(km, weight_in_tons, volume_in_cm3, units)
    trucking_rules_price_machine = TruckingPriceRulesMachine.new(self, km, weight_in_tons, volume_in_cm3, units)

    total_price = trucking_rules_price_machine.total_price
    total_price.round(2)
  end
  def retrieve_trucking_hub(nexus, cargo_type, tenant_id)
    load_type = cargo_type === 'cargo_item' ? 'lcl' : 'fcl'
    trucking_hub_id = "#{nexus.id}_#{load_type}_#{tenant_id}"
    resp = get_item("truckingHubs", '_id', trucking_hub_id)
  end
  def retrieve_trucking_query(trucking_hub, destination, km, direction)
    
    case trucking_hub["modifier"]
      when 'zipcode'
        zip_int = destination.get_zip_code.to_i
        query = [
                  { "zipcode.lower_zip" => { "$lte" => zip_int}},
                  {  "zipcode.upper_zip" => { "$gte" => zip_int }},
                  { 'trucking_hub_id' => { "$eq" => trucking_hub["_id"]}},
                  { 'direction' => { "$eq" => direction}}
                ]
        
        resp = get_items_query('truckingQueries', query).to_a
        if resp
          return resp.first
        end
      
      when 'city'
        
        city_or_query = destination.city.downcase.split.map {|text| {"city.city" => {"$eq" => text}} }
        query = [
                  { "$or" => city_or_query},
                  { 'trucking_hub_id' => { "$eq" => trucking_hub["_id"]}},
                  { 'direction' => { "$eq" => direction}}
                ]
        
        resp = get_items_query('truckingQueries', query).to_a
        if resp
          return resp.first
        end
      
      when 'distance'
        dist = km * 2
        query = [
                  { "distance.lower_distance" => { "$lte" => dist}},
                  {  "distance.upper_distance" => { "$gte" => dist }},
                  { 'trucking_hub_id' => { "$eq" => trucking_hub["_id"]}},
                  { 'direction' => { "$eq" => direction}}
                ]
        
        resp = get_items_query('truckingQueries', query).to_a
        if resp
          return resp.first
        end
      end
  end
  def retrieve_trucking_pricing(trucking_query, cargo, delivery_type)
    
    case trucking_query["modifier"]
      when 'kg'
        query = [
                  { "min_weight" => { "$lte" => cargo["trucking_chargeable_weight"]}},
                  {  "max_weight" => { "$gte" => cargo["trucking_chargeable_weight"] }},
                  { 'trucking_query_id' => { "$eq" => trucking_query["_id"]}},
                  { 'type' => { "$eq" => delivery_type}}
                ]
                # query = [{ "min_weight" => { "$lte" => weight}},{  "max_weight" => { "$gte" => weight }},{ 'trucking_query_id' => { "$eq" => trucking_query["_id"]}},{ "direction" => {"$eq" => direction} } ]
        
        resp = get_items_query('truckingPricings', query).to_a
        
        if resp
          return resp.first
        end
      when 'unit'
        query = [
                  { "all_units" => { "$eq" => ""}},
                  { 'trucking_query_id' => { "$eq" => trucking_query["_id"]}},
                  { 'type' => { "$eq" => delivery_type}}
                ]
                # query = [{ "min_weight" => { "$lte" => weight}},{  "max_weight" => { "$gte" => weight }},{ 'trucking_query_id' => { "$eq" => trucking_query["_id"]}},{ "direction" => {"$eq" => direction} } ]
        
        resp = get_items_query('truckingPricings', query).to_a
        
        if resp
          return resp.first
        end
      end
  end
  def calculate_trucking_price(pricing, cargo, direction)
    fees = {}
    result = {}
    total_fees = {}
    pricing["fees"].each do |k, fee|
      if fee["rate_basis"] != 'PERCENTAGE'
        results = fee_calculator(k, fee, cargo)
         fees[k] = results
      else
        total_fees[k] = fee
      end
      
     
    end
    fees.each do |k, v|

      if !result["value"]
        result["value"] = v[:value]
      else
        result["value"] += v[:value]
      end
      result["currency"] = v[:currency]
    end
    extra_fees_results = {}
    total_fees.each do |tk, tfee|
      extra_fees_results[tk] = tfee["value"] * result["value"]
    end
    extra_fees_results.each do |ek, evalue|
      result["value"] += evalue
    end

      if !pricing["min_value"] || (pricing["min_value"] && result["value"] > pricing["min_value"])
  
        return {value: result["value"], currency: result["currency"] }
      else
  
        return  {value: pricing["min_value"], currency: result["currency"] }
      end

  end
  def fee_calculator(key, fee, cargo)
    case fee["rate_basis"]
      when 'PER_KG'
        return {currency: fee["currency"], value: cargo["trucking_chargeable_weight"] * fee["value"], key: key}
      when 'PER_X_KG'
        return {currency: fee["currency"], value: (cargo["trucking_chargeable_weight"] / fee["base"]) * fee["value"], key: key}
      when 'PER_X_TON'
        return {currency: fee["currency"], value: ((cargo["trucking_chargeable_weight"]/ 1000) / fee["base"]) * fee["value"], key: key}
      when 'PER_SHIPMENT'
        return {currency: fee["currency"], value: fee["value"] / cargo["total_cargo_items"], key: key}
      when 'PER_BILL'
        return {currency: fee["currency"], value: fee["value"] / cargo["total_cargo_items"], key: key}
      when 'PER_ITEM'
        return {currency: fee["currency"], value: fee["value"] * cargo["quantity"], key: key}
      when 'PER_CONTAINER'
        return {currency: fee["currency"], value: fee["value"] * cargo["quantity"], key: key}
      when 'PER_CBM_TON'
        cbm_value = cargo["volume"] * fee["cbm"]
        ton_value = (cargo["trucking_chargeable_weight"]/ 1000) * fee["ton"]
        return_value = ton_value > cbm_value ? ton_value : cbm_value
        return {currency: fee["currency"], value: return_value, key: key}
      when 'PER_CBM_KG'
        cbm_value = cargo["volume"] * fee["cbm"]
        kg_value = cargo["trucking_chargeable_weight"] * fee["kg"]
        return_value = kg_value > cbm_value ? kg_value : cbm_value
        return {currency: fee["currency"], value: return_value, key: key}
      end
  end
  def retrieve_tp_from_array(table, table_key, zip_int, client)
    resp = client[table.to_sym].aggregate([
      { "$match" => { "_id" => table_key }},
      {"$project" => {
          data: {"$filter" => {
              input: '$data',
              as: 'tp',
              cond: { "$and" => [
                  {"$lte" => ["$$tp.lower_zip", zip_int]},
                  {"$gte" => [ "$$tp.upper_zip", zip_int ]}  
                ] 
              }
          }},
          _id: 0
        }
      }
    ])
    p "resp achieved"
    return resp.first["data"][0]
  end

  def retrieve_tp_array(table, table_key, client)
        resp = get_item_fn(table, tableKey, client)
    res = resp.first['data']
    return res
  end


  def calc_trucking_price(destination, cargos, km, hub, target, load_type, direction, delivery_type)
    

    trucking_hub = retrieve_trucking_hub(hub.nexus, load_type, hub.tenant_id)
    
    cargo_object = {}
    cargo_total_items = cargos.map {|c| c.quantity}.sum
    cargos.each do |cargo|
      cargo_object[cargo.id] = cargo.as_json
      cargo_object[cargo.id]["volume"] = cargo.volume
      cargo_object[cargo.id]["total_cargo_items"] = cargo_total_items
      if trucking_hub["load_meterage"]
        if (cargo.dimension_z > trucking_hub["load_meterage"]["height_limit"]) || !cargo.stackable
          load_meterage = (cargo.dimension_x * cargo.dimension_y) / 24000
          load_meter_weight = load_meterage * trucking_hub["load_meterage"]["ratio"]
          trucking_chargeable_weight = load_meter_weight > cargo.payload_in_kg ? load_meter_weight : cargo.payload_in_kg
          cargo_object[cargo.id]["trucking_chargeable_weight"] = trucking_chargeable_weight.to_f
        else
          cbm_ratio = trucking_hub["cbm_ratio"] ? trucking_hub["cbm_ratio"] : 333
          cbm_weight = cargo.volume * cbm_ratio
          trucking_chargeable_weight = cbm_weight > cargo.payload_in_kg ? cbm_weight : cargo.payload_in_kg
          cargo_object[cargo.id]["trucking_chargeable_weight"] = trucking_chargeable_weight.to_f
        end
      else
        cbm_ratio = trucking_hub["cbm_ratio"] ? trucking_hub["cbm_ratio"] : 333
        cbm_weight = cargo.volume * cbm_ratio
        trucking_chargeable_weight = cbm_weight > cargo.payload_in_kg ? cbm_weight : cargo.payload_in_kg
        cargo_object[cargo.id]["trucking_chargeable_weight"] = trucking_chargeable_weight.to_f
      end
      
    end
    trucking_query = retrieve_trucking_query(trucking_hub, destination, km, direction)

    if delivery_type == "" && load_type == 'cargo_item'
      delivery_type = 'default'
    end
    trucking_pricings = {}
    cargo_object.each do |key, cargo|
      
      trucking_pricings[key] = retrieve_trucking_pricing(trucking_query, cargo, delivery_type)
    end
    fees = {}
    
    trucking_pricings.each do |key, pricing|
      fees[key] = calculate_trucking_price(pricing, cargo_object[key], direction)
    end
    total = {value: 0, currency: ''}
    fees.each do |key, trucking_fee|
      total[:value] += trucking_fee[:value]
      total[:currency] = trucking_fee[:currency]
    end
    fees[:total] = total

    return fees
    # hub_trucking_query = get_item_fn(client, 'truckingHubs', "_id", "#{hub.id}")
    # p km
    # if hub && hub.trucking_type
    #   case hub_trucking_query["type"]
    #   when 'zipcode'
    #     if hub_trucking_query["modifier"] == "PER_CBM"
    #       return calc_by_zipcode_cbm(destination, cargo_item.volume_in_cm3, km, hub_trucking_query["table"], client)
    #     else
    #       return calc_by_zipcode_weight(destination, cargo_item.payload_in_kg, km, hub_trucking_query["table"], client)
    #     end
    #   when 'city'
    #     return calc_by_city(hub, destination, km, cargo_item, hub_trucking_query["table"], client, target)
    #   end
    # else
    #   return {value: 1.25 * km, currency: "EUR"}
    # end
  end

  def calc_by_zipcode(destination, cargo_item, km, tpKey, client)
    zc = destination.get_zip_code
    zip_int = zc.gsub!(" ", "").to_i
    tps = retrieve_tp_from_array('truckingTables', tpKey, zip_int, client)
    @selected_rate
    
    if tps
      tps["rate_table"].each do |rate|
        if weight >= rate["min"] && weight <= rate["max"]
          @selected_rate = rate
        end
      end 
      if @selected_rate
        price = (weight / 100) * @selected_rate["value"]
      elsif !@selected_rate && weight < tps["rate_table"][0]["min"]
        @selected_rate = tps["rate_table"][0]
          price = tps["rate_table"][0]["min_value"]
      end
      
      if price > @selected_rate["min_value"]
        return {value:price, currency: tps["currency"]}
      else
        return {value: @selected_rate["min_value"], currency: tps["currency"]}
      end
    else
      
      return {value: 1.25 * km, currency: "EUR"}
    end
  end
  def calc_by_zipcode_cbm(destination, volume, km, tpKey, client)
    zc = destination.get_zip_code
    zip_int = zc.gsub!(" ", "").to_i
    tps = retrieve_tp_from_array('truckingTables', tpKey, zip_int, client)
    @selected_rate
    
    if tps
      tps["rate_table"].each do |rate|
        if weight >= rate["min"] && weight <= rate["max"]
          @selected_rate = rate
        end
      end 
      if @selected_rate
        price = (weight / 100) * @selected_rate["value"]
      elsif !@selected_rate && weight < tps["rate_table"][0]["min"]
        @selected_rate = tps["rate_table"][0]
          price = tps["rate_table"][0]["min_value"]
      end
      
      if price > @selected_rate["min_value"]
        return {value:price, currency: tps["currency"]}
      else
        return {value: @selected_rate["min_value"], currency: tps["currency"]}
      end
    else
      
      return {value: 1.25 * km, currency: "EUR"}
    end
  end
  def calc_by_zipcode_weight(destination, weight, km, tpKey, client)
    zc = destination.get_zip_code
    zip_int = zc.gsub!(" ", "").to_i
    tps = retrieve_tp_from_array('truckingTables', tpKey, zip_int, client)
    @selected_rate
    
    if tps
      tps["rate_table"].each do |rate|
        if weight >= rate["min"] && weight <= rate["max"]
          @selected_rate = rate
        end
      end 
      if @selected_rate
        price = (weight / 100) * @selected_rate["value"]
      elsif !@selected_rate && weight < tps["rate_table"][0]["min"]
        @selected_rate = tps["rate_table"][0]
          price = tps["rate_table"][0]["min_value"]
      end
      
      if price > @selected_rate["min_value"]
        return {value:price, currency: tps["currency"]}
      else
        return {value: @selected_rate["min_value"], currency: tps["currency"]}
      end
    else
      
      return {value: 1.25 * km, currency: "EUR"}
    end
  end

  def calc_by_city(hub, destination, km, cargo_item, tpKey, client, target)
    cbm = (cargo_item.dimension_x * cargo_item.dimension_y * cargo_item.dimension_z) / 1000
    weight = cargo_item.payload_in_kg
    hub_pricings = get_item_fn(client, 'truckingTables', "_id", tpKey)
    hub_pricings["data"].each do |tps|
      if destination.geocoded_address.downcase.include?(tps["city"]) && destination.geocoded_address.downcase.include?(tps["province"])
        p tps["city"]
        p tps["province"]
        p destination.geocoded_address
        @trucking_pricing = tps
      end
    end
    
    # tps = TruckingPricing.find_by("city LIKE ?", "%#{destination.city}%")
    @selected_rate
    if @trucking_pricing
      @trucking_pricing["rate_table"].each do |rate|
        if weight >= rate["min"] && weight <= rate["max"]
          @selected_rate = rate
        end
      end
      price = ((weight) * @selected_rate["value"]) + target == 'origin' ? @selected_rate["pickup_fee"] : @selected_rate["delivery_fee"]
      if !@selected_rate["min_value"] || price > @selected_rate["min_value"]
        return {value:price, currency: @trucking_pricing["currency"]}
      else
        return {value: @selected_rate["min_value"], currency: @trucking_pricing["currency"]}
      end
    else
      return {value: 1.25 * km, currency: "EUR"}
    end
  end
end
