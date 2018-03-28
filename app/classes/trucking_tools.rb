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
  def retrieve_trucking_pricing(location, user, load_type, delivery_type, hub)
    lt = load_type == 'cargo_item' ? 'lcl' : 'fcl'
    sql = "SELECT * FROM trucking_pricings
        JOIN  hub_truckings         ON hub_truckings.trucking_pricing_id     = trucking_pricings.id
        JOIN  trucking_destinations ON hub_truckings.trucking_destination_id = trucking_destinations.id
        JOIN  hubs                  ON hub_truckings.hub_id                  = hubs.id
        JOIN  locations             ON hubs.location_id                      = locations.id
        JOIN  tenants                ON hubs.tenant_id                        = tenants.id
        WHERE tenants.id = #{user.tenant_id}
        AND trucking_pricings.load_type = '#{lt}'
        AND hub.id = #{hub.id}
        AND (
          (
            (trucking_destinations.zipcode IS NOT NULL)
            AND (trucking_destinations.zipcode = '#{location.get_zip_code}')
          ) OR (
            (trucking_destinations.city_name IS NOT NULL)
            AND (trucking_destinations.city_name = '#{location.city}')
          )
        )
        "
        # 
    result = TruckingPricing.find_by_sql(sql)
  end
  def calculate_trucking_price(pricing, cargo, direction, km)
    fees = {}
    result = {}
    total_fees = {}
    
    return {} if pricing.empty?
    
    pricing["fees"].each do |k, fee|
      if fee["rate_basis"] != 'PERCENTAGE'
        results = fee_calculator(k, fee, cargo, km)
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
  def fee_calculator(key, fee, cargo, km)
    case fee["rate_basis"]
      when 'PER_KG'
        return {currency: fee["currency"], value: cargo["weight"] * fee["value"], key: key}
      when 'PER_X_KG'
        return {currency: fee["currency"], value: (cargo["weight"] / fee["base"]) * fee["value"], key: key}
      when 'PER_X_KM'
        return {currency: fee["currency"], value: ((km / fee["x_base"]) * fee["rate"]) + fee["base_value"], key: key}
      when 'PER_X_TON'
        return {currency: fee["currency"], value: ((cargo["weight"]/ 1000) / fee["base"]) * fee["value"], key: key}
      when 'PER_SHIPMENT'
        return {currency: fee["currency"], value: fee["value"] / cargo["number_of_items"], key: key}
      when 'PER_BILL'
        return {currency: fee["currency"], value: fee["value"] / cargo["number_of_items"], key: key}
      when 'PER_ITEM'
        return {currency: fee["currency"], value: fee["value"] * cargo["number_of_items"], key: key}
      when 'PER_CONTAINER'
        return {currency: fee["currency"], value: fee["rate"] * cargo["number_of_items"], key: key}
      when 'PER_CBM_TON'
        cbm_value = cargo["volume"] * fee["cbm"]
        ton_value = (cargo["weight"]/ 1000) * fee["ton"]
        return_value = ton_value > cbm_value ? ton_value : cbm_value
        return {currency: fee["currency"], value: return_value, key: key}
      when 'PER_CBM_KG'
        cbm_value = cargo["volume"] * fee["cbm"]
        kg_value = cargo["weight"] * fee["kg"]
        return_value = kg_value > cbm_value ? kg_value : cbm_value
        return {currency: fee["currency"], value: return_value, key: key}
      end
  end
 
  def filter_trucking_pricings(trucking_pricing, cargo_values, direction)
    return {} if cargo_values["weight"] == 0
    trucking_pricing[direction]["table"].each do |tr|
      
      case trucking_pricing.modifier
      when 'kg'
        if cargo_values["weight"] <= tr["max_weight"] && cargo_values["weight"] >= tr["min_weight"]
          return tr
        end
      when 'unit'
        return tr
      end
    end
  end
  def get_cargo_item_object(trucking_pricing, cargos)
     cargo_object = {
      "stackable" => {
        "volume" =>0,
        "weight" => 0,
        "number_of_items" => 0
      }, "non_stackable" =>  {
        "volume" =>0,
        "weight" => 0,
        "number_of_items" => 0
      }
    }
    cargo_total_items = cargos.map {|c| c.quantity}.sum
    cargos.each do |cargo|
      if trucking_pricing.load_meterage
        if (cargo.dimension_z > trucking_pricing.load_meterage["height_limit"]) || !cargo.stackable
          load_meterage = (cargo.dimension_x * cargo.dimension_y) / 24000
          load_meter_weight = load_meterage * trucking_pricing.load_meterage["ratio"]
          trucking_chargeable_weight = load_meter_weight > cargo.payload_in_kg ? load_meter_weight : cargo.payload_in_kg
          cargo_object["non_stackable"]["weight"] += trucking_chargeable_weight * cargo.quantity
          cargo_object["non_stackable"]["volume"] += cargo.volume * cargo.quantity
          cargo_object["non_stackable"]["number_of_items"] += cargo.quantity
         
        else
          cbm_ratio = trucking_pricing["cbm_ratio"] ? trucking_pricing["cbm_ratio"] : 333
          cbm_weight = cargo.volume * cbm_ratio
          trucking_chargeable_weight = cbm_weight > cargo.payload_in_kg ? cbm_weight : cargo.payload_in_kg
          cargo_object["stackable"]["weight"] += trucking_chargeable_weight * cargo.quantity
          cargo_object["stackable"]["volume"] += cargo.volume * cargo.quantity
          cargo_object["stackable"]["number_of_items"] += cargo.quantity
        end
      else
        cbm_ratio = trucking_pricing["cbm_ratio"] ? trucking_pricing["cbm_ratio"] : 333
        cbm_weight = cargo.volume * cbm_ratio
        trucking_chargeable_weight = cbm_weight > cargo.payload_in_kg ? cbm_weight : cargo.payload_in_kg
        cargo_object["stackable"]["weight"] += trucking_chargeable_weight * cargo.quantity
        cargo_object["stackable"]["volume"] += cargo.volume * cargo.quantity
        cargo_object["stackable"]["number_of_items"] += cargo.quantity
      end
    end
    return cargo_object
  end

  def get_container_object(containers)

    cargo_total_items = containers.map {|c| c.quantity}.sum
    containers.each_with_object({}) do |cargo, cargo_object|
      cargo_object["container_#{cargo.id}"] = {
        "weight" => cargo.payload_in_kg,
        "number_of_items" => cargo.quantity
      }
    end

  end

  def calc_trucking_price(trucking_pricing, cargos, km, direction)
    cargo_object = trucking_pricing.load_type == 'container' ? get_container_object(cargos) : get_cargo_item_object(trucking_pricing, cargos)
    
    trucking_pricings = {}
    cargo_object.each do |stackable_type, cargo_values|
      trucking_pricings[stackable_type] = filter_trucking_pricings(trucking_pricing, cargo_values, direction)
    end
    
    fees = {}
    trucking_pricings.each do |key, tp|
      if  tp
        fees[key] = calculate_trucking_price(tp, cargo_object[key], direction, km)
      end
    end
    
    total = {value: 0, currency: ''}
    fees.each do |key, trucking_fee|
      unless trucking_fee.empty?
        total[:value] += trucking_fee[:value]
        total[:currency] = trucking_fee[:currency]
      end
    end
    
    fees[:total] = total
    return fees
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
