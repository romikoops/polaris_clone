module ExcelTools
  include ImageTools
  include MongoTools
  
  def overwrite_main_carriage_rates(params, dedicated, user = current_user)
    old_route_ids = Route.pluck(:id)
    old_pricing_ids = Pricing.where(dedicated: dedicated).pluck(:id)
    new_route_ids = []
    new_pricing_ids = []

    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    pricing_rows = first_sheet.parse(
      customer_id: 'CUSTOMER_ID',
      effective_date: 'EFFECTIVE_DATE',
      expiration_date: 'EXPIRATION_DATE',
      origin: 'ORIGIN',
      destination: 'DESTINATION',
      lcl_currency: 'LCL_CURRENCY',
      lcl_rate_wm: 'LCL_RATE_WM',
      lcl_rate_min: 'LCL_RATE_MIN',
      lcl_heavy_weight_surcharge_wm: 'LCL_HEAVY_WEIGHT_SURCHARGE_WM',
      lcl_heavy_weight_surcharge_min: 'LCL_HEAVY_WEIGHT_SURCHARGE_MIN',
      fcl_20_currency: 'FCL_20_CURRENCY',
      fcl_20_rate: 'FCL_20_RATE',
      fcl_20_heavy_weight_surcharge_wm: 'FCL_20_HEAVY_WEIGHT_SURCHARGE_WM',
      fcl_20_heavy_weight_surcharge_min: 'FCL_20_HEAVY_WEIGHT_SURCHARGE_MIN',
      fcl_40_currency: 'FCL_40_CURRENCY',
      fcl_40_rate: 'FCL_40_RATE',
      fcl_40_heavy_weight_surcharge_wm: 'FCL_40_HEAVY_WEIGHT_SURCHARGE_WM',
      fcl_40_heavy_weight_surcharge_min: 'FCL_40_HEAVY_WEIGHT_SURCHARGE_MIN',
      fcl_40_hq_currency: 'FCL_40_HQ_CURRENCY',
      fcl_40_hq_rate: 'FCL_40_HQ_RATE',
      fcl_40_hq_heavy_weight_surcharge_wm: 'FCL_40_HQ_HEAVY_WEIGHT_SURCHARGE_WM',
      fcl_40_hq_heavy_weight_surcharge_min: 'FCL_40_HQ_HEAVY_WEIGHT_SURCHARGE_MIN'
    )


    pricing_rows.each do |row|
      origin = Location.find_by(name: row[:origin])
      destination = Location.find_by(name: row[:destination])
      route = Route.find_or_create_by!(name: "#{origin.name} - #{destination.name}", tenant_id: user.tenant_id, origin_nexus_id: origin.id, destination_nexus_id: destination.id)
      route.generate_weekly_schedules('ocean', row[:effective_date], row[:expiration_date], [1,5], 30)
      new_route_ids << route.id
      if !dedicated
        cust_id = nil
        ded_bool = false
      elsif !row[:customer_id] && dedicated
        cust_id = user.id
        ded_bool = false
      elsif row[:customer_id] && dedicated
        cust_id = row[:customer_id].to_i
        ded_bool = true
      end
      lcl_obj = {
        currency: row[:lcl_currency],
        wm_rate: row[:lcl_rate_wm],
        wm_min: row[:lcl_rate_min],
        heavy_weight: row[:lcl_heavy_weight_surcharge_wm],
        heavy_wm_min: row[:lcl_heavy_weight_surcharge_min]
      }

      fcl_20f_obj = {
        currency: row[:fcl_20_currency],
        rate: row[:fcl_20_rate],
        heavy_weight: row[:fcl_20_heavy_weight_surcharge_wm],
        heavy_kg_min: row[:fcl_20_heavy_weight_surcharge_min]
      }

      fcl_40f_obj = {
        currency: row[:fcl_40_currency],
        rate: row[:fcl_40_rate],
        heavy_weight: row[:fcl_40_heavy_weight_surcharge_wm],
        heavy_kg_min: row[:fcl_40_heavy_weight_surcharge_min]
      }

      fcl_40f_hq_obj = {
        currency: row[:fcl_40_hq_currency],
        rate: row[:fcl_40_hq_rate],
        heavy_weight: row[:fcl_40_hq_heavy_weight_surcharge_wm],
        heavy_kg_min: row[:fcl_40_hq_heavy_weight_surcharge_min]
      }

      pricing = route.pricings.find_or_create_by(dedicated: ded_bool, tenant_id: user.tenant_id, customer_id: cust_id, lcl: lcl_obj, fcl_20f: fcl_20f_obj, fcl_40f: fcl_40f_obj, fcl_40f_hq: fcl_40f_hq_obj)

      new_pricing_ids << pricing.id
    end

    kicked_route_ids = old_route_ids - new_route_ids
    Route.where(id: kicked_route_ids).destroy_all

    kicked_pricing_ids = old_pricing_ids -new_pricing_ids
    Pricing.where(id: kicked_pricing_ids).destroy_all
  end

  def overwrite_trucking_rates(params, user = current_user)
    old_trucking_ids = nil
    new_trucking_ids = []

    defaults = []
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      nexus = Location.find_by(name: sheet_name, location_type: "nexus")
      old_trucking_ids = TruckingPricing.where(nexus_id: nexus.id).pluck(:id)

      currency_row = first_sheet.row(1)

      header_row = first_sheet.row(2)
      header_row.shift
      header_row.shift
      weight_min_row = first_sheet.row(3)
      weight_min_row.shift
      weight_min_row.shift
      num_rows = first_sheet.last_row
      header_row.each do |cell|
        min_max_arr = cell.split(" - ")
        defaults.push({min: min_max_arr[0].to_i, max: min_max_arr[1].to_i, value: nil, min_value: nil})
      end
      (4..num_rows).each do |line|
        row_data = first_sheet.row(line)
        zip_code_range_array = row_data.shift.split(" - ")
        # zip_code_range = (zip_code_range_array[0].to_i..zip_code_range_array[1].to_i)
        row_min_value = row_data.shift
        ntp = TruckingPricing.new(currency: currency_row[3], tenant_id: user.tenant_id, nexus_id: nexus.id, lower_zip: zip_code_range_array[0].to_i, upper_zip: zip_code_range_array[1].to_i)
        row_data.each_with_index do |val, index|
          tmp = defaults[index]
          if row_min_value < weight_min_row[index]
            min_value = weight_min_row[index]
          else
            min_value = row_min_value
          end
          tmp[:min_value] = min_value
          tmp[:value] = val
          ntp.rate_table.push(tmp)

          ntp.save!

          new_trucking_ids << ntp.id
        end
      end
    end

    kicked_trucking_ids = old_trucking_ids - new_trucking_ids
    TruckingPricing.where(id: kicked_trucking_ids).destroy_all
  end

  def overwrite_shanghai_trucking_rates(params, user = current_user)
    old_trucking_ids = nil
    new_trucking_ids = []

    defaults = []
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      nexus = Location.find_by(name: sheet_name, location_type: "nexus")
      old_trucking_ids = TruckingPricing.where(nexus_id: nexus.id).pluck(:id)

      weight_cat_row = first_sheet.row(2)
      num_rows = first_sheet.last_row
      [3,4,5,6].each do |i|
        min_max_arr = weight_cat_row[i].split(" - ")
        defaults.push({min: min_max_arr[0].to_i, max: min_max_arr[1].to_i, value: nil, min_value: nil})
      end
      (3..num_rows).each do |line|
        row_data = first_sheet.row(line)
        new_pricing = {}

        new_pricing[:province] = row_data[0].downcase
        new_pricing[:city] = row_data[1].downcase
        new_pricing[:dist_hub] = row_data[2].split(' , ')
        new_pricing[:currency] = "CNY"
        new_pricing[:tenant_id] = user.tenant_id
        new_pricing[:nexus_id] = nexus.id
        new_pricing[:rate_type] = "city"
        new_pricing[:rate_table] = []
        ntp = TruckingPricing.new(new_pricing)

        [3,4,5,6].each do |i|
          tmp = defaults[i - 3]
          tmp[:value] = row_data[i]
          tmp[:pickup_fee] = row_data[8]
          tmp[:delivery_fee] = row_data[9]
          tmp[:delivery_eta_in_days] = row_data[10]
          tmp[:per_cbm_rate] = row_data[7]

          ntp.rate_table.push(tmp)
        end
        ntp.save!

        new_trucking_ids << ntp.id

      end
    end

    kicked_trucking_ids = old_trucking_ids - new_trucking_ids
    TruckingPricing.where(id: kicked_trucking_ids).destroy_all
  end

  def overwrite_service_charges(params, user = current_user)
    old_ids = ServiceCharge.pluck(:id)
    new_ids = []

    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)

    rows = first_sheet.parse
    rows.each do |r|
      new_charge = {
        effective_date: r[0],
        expiration_date: r[1],
        hub_code: r[2],
        terminal_handling_cbm: {currency: r[3], value: r[4], trade_direction: "export"},
        terminal_handling_ton: {currency: r[3], value: r[5], trade_direction: "export"},
        terminal_handling_min: {currency: r[3], value: r[6], trade_direction: "export"},
        lcl_service_cbm: {currency: r[7], value: r[8], trade_direction: "export"},
        lcl_service_ton: {currency: r[7], value: r[9], trade_direction: "export"},
        lcl_service_min: {currency: r[7], value: r[10], trade_direction: "export"},
        isps: {currency: r[11], value: r[12], trade_direction: "export"},
        exp_declaration: {currency: r[13], value: r[14], trade_direction: "export"},
        extra_hs_code: {currency: r[15], value: r[16], trade_direction: "export"},
        doc_fee: {currency: r[17], value: r[18], trade_direction: "export"},
        liner_service_fee: {currency: r[19], value: r[20], trade_direction: "export"},
        vgm_fee: {currency: r[21], value: r[22], trade_direction: "export"},
        documentation_fee: {currency: r[23], value: r[24], trade_direction: "import"},
        handling_fee: {currency: r[25], value: r[26], trade_direction: "import"},
        customs_clearance: {currency: r[27], value: r[28], trade_direction: "import"},
        cfs_terminal_charges: {currency: r[29], value: r[30], trade_direction: "import"}
      }
      p new_charge[:hub_code]
      p user.tenant_id
      hub = Hub.find_by("hub_code = ? AND tenant_id = ?", new_charge[:hub_code], user.tenant_id)
      new_charge.delete(:hub_code)
      new_charge[:hub_id] = hub.id

      if hub.service_charge
        hub.service_charge.destroy
      end

      sc = ServiceCharge.create(new_charge)
      hub.service_charge = sc
    end

    # service_charge_rows.each do |service_charge_row|

    #   service_charge_row.each do |k, v|
    #     service_charge_row[k] = 0 if v == "-"
    #     service_charge_row[k] = 0 if v.nil?
    #   end
    #   sc = ServiceCharge.find_or_create_by(service_charge_row)
    #   new_ids << sc.id
    # end

    # kicked_sc_ids = old_ids - new_ids
    # ServiceCharge.where(id: kicked_sc_ids).destroy_all
  end

  def overwrite_air_schedules(params, user = current_user)
    old_ids = Schedule.pluck(:id)
    new_ids = []
    locations = {}
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    schedules = first_sheet.parse(vessel: 'VESSEL', call_sign: 'VOYAGE_CODE', from: 'FROM', to: 'TO', eta: 'ETA', etd: 'ETS')

    schedules.each do |row|
      row[:mode_of_transport] = "air"

      if locations[row[:from]] && locations[row[:to]]
        route = Route.find_by("origin_id = ? AND destination_id = ?", locations[row[:from]].id, locations[row[:to]].id)
      else
        locations[row[:from]] = Location.find_by_name(row[:from])
        locations[row[:to]] = Location.find_by_name(row[:to])

        route = Route.find_by("origin_id = ? AND destination_id = ?", locations[row[:from]].id, locations[row[:to]].id)
      end

      hubroute = HubRoute.create_from_route(route, row[:mode_of_transport])

      vt = TenantVehicle.find_by(tenant_id: user.tenant_id, mode_of_transport: row[:mode_of_transport])

      hub1 = locations[row[:from]].hubs_by_type(row[:mode_of_transport]).first
      hub2 = locations[row[:to]].hubs_by_type(row[:mode_of_transport]).first

      row[:vehicle_id] = vt.vehicle_id
      row[:hub_route_key] = "#{hubroute.starthub_id}-#{hubroute.endhub_id}"
      row[:tenant_id] = user.tenant_id
      row.delete(:from)
      row.delete(:to)

      if route
        sched = route.schedules.find_or_create_by(row)
        # new_ids << sched.id
      else
        raise "Route cannot be found!"
      end
    end

    # kicked_vs_ids = old_ids - new_ids
    # Schedule.where(id: kicked_vs_ids).destroy_all
  end

  def overwrite_vessel_schedules(params, user = current_user)
    # old_ids = Schedule.pluck(:id)
    # new_ids = []
    locations = {}
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    schedules = first_sheet.parse(vessel: 'VESSEL', call_sign: 'VOYAGE_CODE', from: 'FROM', to: 'TO', eta: 'ETA', etd: 'ETS')

    schedules.each do |row|
      row[:mode_of_transport] = "ocean"

      if locations[row[:from]] && locations[row[:to]]
        route = Route.find_by("origin_nexus_id = ? AND destination_nexus_id = ?", locations[row[:from]].id, locations[row[:to]].id)
      else
        locations[row[:from]] = Location.find_by_name(row[:from])
        locations[row[:to]] = Location.find_by_name(row[:to])

        route = Route.find_by("origin_nexus_id = ? AND destination_nexus_id = ?", locations[row[:from]].id, locations[row[:to]].id)
      end
      hubroute = HubRoute.create_from_route(route, row[:mode_of_transport])

      vt = TenantVehicle.find_by(tenant_id: user.tenant_id, mode_of_transport: row[:mode_of_transport])

      row[:tenant_id] = user.tenant_id
      row[:vehicle_id] = vt.vehicle_id
      row[:hub_route_key] = "#{hubroute.starthub_id}-#{hubroute.endhub_id}"
      row.delete(:from)
      row.delete(:to)

      if route
        sched = hubroute.schedules.find_or_create_by(row)
        # new_ids << sched.id
      else
        raise "Route cannot be found!"
      end
    end

    # kicked_vs_ids = old_ids - new_ids
    # Schedule.where(id: kicked_vs_ids).destroy_all
  end

  def overwrite_train_schedules(params, user = current_user)
    # old_ids = Schedule.pluck(:id)
    # new_ids = []
    data_box = {}
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    schedules = first_sheet.parse(from: 'FROM', to: 'TO', eta: 'ETA', etd: 'ETD')

    schedules.each do |train_schedule|
      # begin
      train_schedule[:mode_of_transport] = 'train'
      if data_box[train_schedule[:from]] && data_box[train_schedule[:to]]
        robj = Route.where("origin_id = ? AND destination_id = ?", data_box[train_schedule[:from]], data_box[train_schedule[:to]]).first
      else
        data_box[train_schedule[:from]] = Location.find_by_hub_name(train_schedule[:from])
        data_box[train_schedule[:to]] = Location.find_by_hub_name(train_schedule[:to])
        robj = Route.where("origin_id = ? AND destination_id = ?", data_box[train_schedule[:from]], data_box[train_schedule[:to]]).first
      end
      hubroute = HubRoute.create_from_route(route, row[:mode_of_transport])

      vt = TenantVehicle.find_by(tenant_id: user.tenant_id, mode_of_transport: row[:mode_of_transport])

      hub1 = locations[row[:from]].hubs_by_type("rail").first
      hub2 = locations[row[:to]].hubs_by_type("rail").first
      row[:tenant_id] = user.tenant_id
      row[:vehicle_id] = vt.vehicle_id
      row[:hub_route_key] = "#{hubroute.starthub_id}-#{hubroute.endhub_id}"
      if robj
        ts = robj.schedules.find_or_create_by(train_schedule)
      else
        raise "Route cannot be found!"
      end
    end
  end

  def overwrite_hubs(params, user = current_user)
    hubs = []

    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)

    hub_rows = first_sheet.parse( hub_status: 'STATUS', hub_type: 'TYPE', hub_name: 'NAME', hub_code: 'CODE', trucking_type: 'TRUCKING_METHOD', hub_operator: 'OPERATOR', latitude: 'LATITUDE', longitude: 'LONGITUDE', country: 'COUNTRY', geocoded_address: 'FULL_ADDRESS', hub_address_details: 'ADDRESS_DETAILS', photo: 'PHOTO')

    hub_type_name = {
      "ocean" => "Port",
      "air" => "Airport",
      "rail" => "Railway Station"
    }

    hub_rows.each do |hub_row|
      hub_row[:hub_type] = hub_row[:hub_type].downcase
      nexus = Location.find_or_create_by(name: hub_row[:hub_name], location_type: "nexus", latitude: hub_row[:latitude], longitude: hub_row[:longitude], photo: hub_row[:photo])

      unless hub_row[:hub_code].blank?
        hub_code = hub_row[:hub_code]
      end

      hub = nexus.hubs.find_or_create_by(hub_code: hub_code, location_id: nexus.id, tenant_id: user.tenant_id, hub_type: hub_row[:hub_type], trucking_type: hub_row[:trucking_type], latitude: hub_row[:latitude], longitude: hub_row[:longitude], name: "#{nexus.name} #{hub_type_name[hub_row[:hub_type]]}", photo: hub_row[:photo])
      hubs << hub
    end
    hubs.each do |hub|
      hub.generate_hub_code!(user.tenant_id)
    end
  end

  def load_hub_images(params)
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)

    hub_rows = first_sheet.parse(hub_name: 'NAME', url: 'URL')

    hub_rows.each do |hub_row|
      imgstr = reduce_and_upload(hub_row[:hub_name], hub_row[:url])
      nexus = Location.find_by_name(hub_row[:hub_name])
      nexus.update_attributes(photo: imgstr[:sm])
      nexus.save!
    end
  end

  def overwrite_mongo_pricings(params, dedicated, user = current_user)
    # old_pricing_ids = Pricing.where(dedicated: dedicated).pluck(:id)
    mongo = get_client
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    pricing_rows = first_sheet.parse(
      customer_id: 'CUSTOMER_ID',
      effective_date: 'EFFECTIVE_DATE',
      expiration_date: 'EXPIRATION_DATE',
      origin: 'ORIGIN',
      vehicle_type: 'VEHICLE_TYPE',
      mot: 'MOT',
      cargo_type: 'CARGO_TYPE',
      destination: 'DESTINATION',
      lcl_currency: 'LCL_CURRENCY',
      lcl_rate_wm: 'LCL_RATE_WM',
      lcl_rate_min: 'LCL_RATE_MIN',
      lcl_heavy_weight_surcharge_wm: 'LCL_HEAVY_WEIGHT_SURCHARGE_WM',
      lcl_heavy_weight_surcharge_min: 'LCL_HEAVY_WEIGHT_SURCHARGE_MIN',
      fcl_20_currency: 'FCL_20_CURRENCY',
      fcl_20_rate: 'FCL_20_RATE',
      fcl_20_heavy_weight_surcharge_wm: 'FCL_20_HEAVY_WEIGHT_SURCHARGE_WM',
      fcl_20_heavy_weight_surcharge_min: 'FCL_20_HEAVY_WEIGHT_SURCHARGE_MIN',
      fcl_40_currency: 'FCL_40_CURRENCY',
      fcl_40_rate: 'FCL_40_RATE',
      fcl_40_heavy_weight_surcharge_wm: 'FCL_40_HEAVY_WEIGHT_SURCHARGE_WM',
      fcl_40_heavy_weight_surcharge_min: 'FCL_40_HEAVY_WEIGHT_SURCHARGE_MIN',
      fcl_40_hq_currency: 'FCL_40_HQ_CURRENCY',
      fcl_40_hq_rate: 'FCL_40_HQ_RATE',
      fcl_40_hq_heavy_weight_surcharge_wm: 'FCL_40_HQ_HEAVY_WEIGHT_SURCHARGE_WM',
      fcl_40_hq_heavy_weight_surcharge_min: 'FCL_40_HQ_HEAVY_WEIGHT_SURCHARGE_MIN'
    )
    new_pricings = []
    new_path_pricings = {}
    
    pricing_rows.each do |row|
      origin = Location.find_by(name: row[:origin])
      destination = Location.find_by(name: row[:destination])
      route = Route.find_or_create_by!(name: "#{origin.name} - #{destination.name}", tenant_id: user.tenant_id, origin_nexus_id: origin.id, destination_nexus_id: destination.id)
      hubroute = HubRoute.create_from_route(route, row[:mot])

      if !row[:vehicle_type]
        vt = Vehicle.find_by_name("#{row[:mot]}_default")
      else
        vt = Vehicle.find_by_name(row[:vehicle_type])
      end

      load_types = [
        'fcl_20f',
        'fcl_40f',
        'fcl_40f_hq',
        'lcl'
      ]

      tt_obj = {}

      if !row[:cargo_type]
        load_types.each do |lt|
          tt_obj[lt] = vt.transport_categories.find_by(name: "any", cargo_class: lt)
        end
      else
        load_types.each do |lt|
          tt_obj[lt] = vt.transport_categories.find_by(name: row[:cargo_type], cargo_class: lt)
        end
      end

      hubroute.generate_weekly_schedules(row[:mot], row[:effective_date], row[:expiration_date], [1,5], 30, vt.id)

      if !dedicated
        cust_id = nil
        ded_bool = false
      elsif !row[:customer_id] && dedicated
        cust_id = user.id
        ded_bool = false
      elsif row[:customer_id] && dedicated
        cust_id = row[:customer_id].to_i
        ded_bool = true
      end

      lcl_obj = {
        wm:{
          currency: row[:lcl_currency],
          rate: row[:lcl_rate_wm],
          min: row[:lcl_rate_min]
        },
        heavy_wm: {
          currency: row[:lcl_currency],
          heavy_weight: row[:lcl_heavy_weight_surcharge_wm],
        heavy_wm_min: row[:lcl_heavy_weight_surcharge_min]}
      }

      fcl_20f_obj = {
        wm:{
          currency: row[:fcl_20_currency],
          rate: row[:fcl_20_rate]
        },
        heavy_kg:{
          currency: row[:fcl_20_currency],
          heavy_weight: row[:fcl_20_heavy_weight_surcharge_wm],
          heavy_kg_min: row[:fcl_20_heavy_weight_surcharge_min]
        }
      }

      fcl_40f_obj = {
        wm:{
          currency: row[:fcl_40_currency],
          rate: row[:fcl_40_rate]
        },
        heavy_kg:{
          currency: row[:fcl_40_currency],
          heavy_weight: row[:fcl_40_heavy_weight_surcharge_wm],
          heavy_kg_min: row[:fcl_40_heavy_weight_surcharge_min]
        }
      }

      fcl_40f_hq_obj = {
        wm:{
          currency: row[:fcl_40_hq_currency],
          rate: row[:fcl_40_hq_rate]
        },
        heavy_kg:{
          currency: row[:fcl_40_hq_currency],
          heavy_weight: row[:fcl_40_hq_heavy_weight_surcharge_wm],
          heavy_kg_min: row[:fcl_40_hq_heavy_weight_surcharge_min]
        }
      }

      price_obj = {"lcl" =>lcl_obj.to_h, "fcl_20f" =>fcl_20f_obj.to_h, "fcl_40f" =>fcl_40f_obj.to_h, "fcl_40f_hq" =>fcl_40f_hq_obj.to_h}

      if dedicated
        load_types.each do |lt|
          uuid = SecureRandom.uuid
          tmpItem = price_obj[lt]
          pathKey = "#{hubroute.id}_#{tt_obj[lt].id}"
          tmpItem[:_id] = uuid;
          tmpItem[:tenant_id] = user.tenant_id;
          userObj = {}
          userObj[pathKey] = uuid
          put_item_fn(mongo, 'pricings', tmpItem)
          if !new_path_pricings[pathKey]
            new_path_pricings[pathKey] = {}
          end
          update_item_fn(mongo, 'userPricings', {_id: "#{user.id}"}, userObj)
          new_path_pricings[pathKey]["#{user.id}"] = uuid
        end
      else
        load_types.each do |lt|
          uuid = SecureRandom.uuid
          tmpItem = price_obj[lt]
          pathKey = "#{hubroute.id}_#{tt_obj[lt].id}"
          tmpItem[:_id] = uuid;
          tmpItem[:tenant_id] = user.tenant_id
          pr = put_item_fn(mongo, 'pricings', tmpItem)

          if !new_path_pricings[pathKey]
            new_path_pricings[pathKey] = {}
          end

          new_path_pricings[pathKey]["open"] = uuid
          new_path_pricings[pathKey]["hub_route"] = hubroute.id
          new_path_pricings[pathKey]["tenant_id"] = user.tenant_id
          new_path_pricings[pathKey]["route"] = route.id
          new_path_pricings[pathKey]["transport_category"] = tt_obj[lt].id
        end
      end
    end

    npps = []
    new_path_pricings.each do |key, value|
      tmpObj = value
      ppr = update_item_fn(mongo, 'pathPricing', {_id: key }, tmpObj)
    end
  end
end
