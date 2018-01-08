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


  def calc_trucking_price(destination, cargo_item, km, hub, client)
    hub_trucking_query = get_item_fn(client, 'truckingHubs', "_id", "#{hub.id}")
    p km
    if hub && hub.trucking_type
      case hub_trucking_query["type"]
      when 'zipcode'
        return calc_by_zipcode(destination, cargo_item.payload_in_kg, km, hub_trucking_query["table"], client)
      when 'city'
        return calc_by_city(hub, destination, km, cargo_item, hub_trucking_query["table"], client)
      end
    else
      return {value: 1.25 * km, currency: "EUR"}
    end
  end

  def calc_by_zipcode(destination, weight, km, tpKey, client)
    zc = destination.get_zip_code
    zip_int = zc.gsub!(" ", "").to_i
<<<<<<< HEAD
    # tps = TruckingPricing.find_by("? < upper_zip AND ? > lower_zip", zip_int, zip_int)
    # tps = query_table('truckingTables', {"_id" => tpKey}, { "data" => {"$and" => [ { "lower_zip" => { "$gte" => zip_int } }, { "upper_zip" => { "$lte" => zip_int } } ] } })
=======
>>>>>>> 48dff554df16a4a5ad7c7a89d735cb59e677ded6
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
      byebug
      return {value: 1.25 * km, currency: "EUR"}
    end
  end

  def calc_by_city(hub, destination, km, cargo_item, tpKey, client)
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
      price = ((weight) * @selected_rate["value"]) + @selected_rate["pickup_fee"] + @selected_rate["delivery_fee"]
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
