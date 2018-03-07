module ExcelTools
  include ImageTools
  include MongoTools
  include PricingTools

  def overwrite_zipcode_weight_trucking_rates(params, user = current_user, direction)
    # old_trucking_ids = nil
    # new_trucking_ids = []
    mongo = get_client
    defaults = []
    load_type = "lcl"
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      nexus = Location.find_by(name: sheet_name, location_type: "nexus")

      currency_row = first_sheet.row(1)
      hubs = nexus.hubs
      header_row = first_sheet.row(2)
      header_row.shift
      header_row.shift
      weight_min_row = first_sheet.row(3)
      weight_min_row.shift
      weight_min_row.shift
      num_rows = first_sheet.last_row
      header_row.each do |cell|
        min_max_arr = cell.split(" - ")
        defaults.push({min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil})
      end
      trucking_table_id = "#{nexus.id}_#{load_type}_#{user.tenant_id}" 
      truckingQueries = []
      truckingTable = "#{nexus.id}_#{load_type}_#{user.tenant_id}"
      truckingPricings = []
      (4..num_rows).each do |line|
        # byebug
        row_data = first_sheet.row(line)
        zip_code_range_array = row_data.shift.split(" - ")
        # zip_code_range = (zip_code_range_array[0].to_i..zip_code_range_array[1].to_i)
        row_min_value = row_data.shift
        # ntp = TruckingPricing.new(currency: currency_row[3], tenant_id: user.tenant_id, nexus_id: nexus.id, lower_zip: zip_code_range_array[0].to_i, upper_zip: zip_code_range_array[1].to_i)
        ntp = {
          trucking_hub_id: trucking_table_id,
          tenant_id: user.tenant_id,
          nexus_id: nexus.id,
          direction: direction,
          _id: SecureRandom.uuid,
          modifier: 'kg',
          zipcode: {
            lower_zip: zip_code_range_array[0].to_i,
            upper_zip: zip_code_range_array[1].to_i
          }
        }
        row_data.each_with_index do |val, index|
          tmp = defaults[index].clone
          if row_min_value < weight_min_row[index]
            min_value = weight_min_row[index]
          else
            min_value = row_min_value
          end
          tmp[:min_value] = min_value
          tmp[:fees] = {  
            base_rate: {
              value: val,
              rate_basis: 'PER_X_KG',
              currency: currency_row[3],
              base: 100
            }
          }
          tmp[:direction] = direction
          tmp[:type] = "default"
          tmp[:_id] = SecureRandom.uuid
          tmp[:trucking_hub_id] = trucking_table_id
          tmp[:trucking_query_id] = ntp[:_id]
          truckingPricings.push(tmp)
          # byebug
        end
        truckingQueries.push(ntp)
      end
      # byebug
      truckingQueries.each do |k|
        update_item_fn(mongo,  'truckingQueries', {_id: k[:_id]}, k)
      end
      truckingPricings.each do |k|
        update_item_fn(mongo,  'truckingPricings', {_id: k[:_id]}, k)
      end
      update_item_fn(mongo, 'truckingHubs', {_id: trucking_table_id}, {modifier: "zipcode", tenant_id: user.tenant_id, nexus_id: nexus.id, load_type: 'lcl'})

    end

  end

  def overwrite_zipcode_cbm_trucking_rates(params, user = current_user)
    # old_trucking_ids = nil
    # new_trucking_ids = []
    mongo = get_client
    defaults = []
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      nexus = Location.find_by(name: sheet_name, location_type: "nexus")

      currency_row = first_sheet.row(1)
      hubs = nexus.hubs
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
      results = []
      truckingTable = "#{nexus.id}_#{user.tenant_id}" 
      (4..num_rows).each do |line|
        row_data = first_sheet.row(line)
        zip_code_range_array = row_data.shift.split(" - ")
        # zip_code_range = (zip_code_range_array[0].to_i..zip_code_range_array[1].to_i)
        row_min_value = row_data.shift
        # ntp = TruckingPricing.new(currency: currency_row[3], tenant_id: user.tenant_id, nexus_id: nexus.id, lower_zip: zip_code_range_array[0].to_i, upper_zip: zip_code_range_array[1].to_i)
        ntp = {currency: currency_row[3], tenant_id: user.tenant_id, nexus_id: nexus.id, lower_zip: zip_code_range_array[0].to_i, upper_zip: zip_code_range_array[1].to_i, rate_table: []}
        row_data.each_with_index do |val, index|
          tmp = defaults[index]
          if row_min_value < weight_min_row[index]
            min_value = weight_min_row[index]
          else
            min_value = row_min_value
          end
          tmp[:min_value] = min_value
          tmp[:value] = val
          ntp[:rate_table].push(tmp)

          

          # new_trucking_ids << ntp.id
        end
        # p ntp
        results << ntp
        # update_array_fn(mongo, 'truckingTables', {_id: truckingTable}, ntp)
      end
      # 
      update_array_fn(mongo,  'truckingTables', {_id: truckingTable}, results)
      hubs.each do |h|
        update_item_fn(mongo, 'truckingHubs', {_id: "#{h.id}"}, {type: "zipcode", table: truckingTable, tenant_id: user.tenant_id, nexus_id: nexus.id})
      end
    end

    # kicked_trucking_ids = old_trucking_ids - new_trucking_ids
    # TruckingPricing.where(id: kicked_trucking_ids).destroy_all
  end

  def overwrite_city_trucking_rates(params, user = current_user, direction)
    
    mongo = get_client
    defaults = []
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      nexus = Location.find_by(name: sheet_name, location_type: "nexus")
      # old_trucking_ids = TruckingPricing.where(nexus_id: nexus.id).pluck(:id)
      truckingPricings = []
      truckingQueries = []
      hubs = nexus.hubs
      trucking_table_id = "#{nexus.id}_lcl_#{user.tenant_id}"  
      weight_cat_row = first_sheet.row(2)
      num_rows = first_sheet.last_row
      [3,4,5,6].each do |i|
        min_max_arr = weight_cat_row[i].split(" - ")
        defaults.push({min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil})
      end
      (3..num_rows).each do |line|
        row_data = first_sheet.row(line)
        new_pricing = {}

        new_pricing[:city] = {
          province: row_data[0].downcase,
          city: row_data[1].downcase,
          dist_hub: row_data[2].split(' , ')
      }
        new_pricing[:currency] = "CNY"
        new_pricing[:tenant_id] = user.tenant_id
        new_pricing[:nexus_id] = nexus.id
        new_pricing[:trucking_hub_id] = trucking_table_id
        new_pricing[:delivery_eta_in_days] = row_data[10]
        new_pricing[:modifier] = 'kg'
        new_pricing[:direction] = direction
        ntp = new_pricing
        ntp[:_id] = SecureRandom.uuid
        [3,4,5,6].each do |i|
          tmp = defaults[i - 3].clone
          tmp[:_id] = SecureRandom.uuid
          tmp[:type] = "default"
          tmp[:fees] = {
            base_rate: {
              kg: row_data[i],
              cbm: row_data[7],
              rate_basis: 'PER_CBM_KG',
              currency: "CNY"
            }
          }
          if  direction === 'export'
            tmp[:fees][:PUF] = {value: row_data[8], currency: new_pricing[:currency], rate_basis: 'PER_SHIPMENT' }
          else
            tmp[:fees][:DLF] = {value: row_data[9], currency: new_pricing[:currency], rate_basis: 'PER_SHIPMENT' }
          end
          tmp[:trucking_query_id] = ntp[:_id]
         
          truckingPricings.push(tmp)
        end
        truckingQueries << ntp
        new_trucking_location = Location.from_short_name("#{new_pricing[:city][:city]} ,#{new_pricing[:city][:province]}", 'trucking_option')
        new_trucking_option = TruckingOption.create(nexus_id: nexus.id, city_name: new_pricing[:city][:city], location_id: new_trucking_location.id, tenant_id: user.tenant_id)
        hubs.each do |hub|
          HubTruckingOption.create(hub_id: hub.id, trucking_option_id: new_trucking_option.id)
        end
      end
      update_item_fn(mongo, 'truckingHubs', {_id: trucking_table_id}, {modifier: "city", tenant_id: user.tenant_id, nexus_id: nexus.id})
      truckingQueries.each do |k|
        update_item_fn(mongo,  'truckingQueries', {_id: k[:_id]}, k)
      end
      truckingPricings.each do |k|
        update_item_fn(mongo,  'truckingPricings', {_id: k[:_id]}, k)
      end
    end

    # kicked_trucking_ids = old_trucking_ids - new_trucking_ids
    # TruckingPricing.where(id: kicked_trucking_ids).destroy_all
  end

  def overwrite_local_charges(params, user = current_user)
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      hub = Hub.find_by(name: sheet_name, tenant_id: user.tenant_id)
      
      rows = first_sheet.parse(
        fee: 'FEE',
        mot: 'MOT',
        fee_code: 'FEE_CODE',
        load_type: 'LOAD_TYPE',
        direction:	'DIRECTION',
        currency:	'CURRENCY',
        rate_basis:	'RATE_BASIS',
        ton: 'TON',
        cbm: 'CBM',
        kg: 'KG',
        item: 'ITEM',
        shipment: 'SHIPMENT',
        bill: 'BILL',
        container: 'CONTAINER',
        minimum: 'MINIMUM'
      )
      hub_fees = {}
      ['lcl', 'fcl_20', 'fcl_40', 'fcl_40hq'].each do |lt|
       hub_fees[lt] = {
        "import" => {},
        "export" => {},
        "mode_of_transport" => rows[0][:mot],
        "nexus_id" => hub.nexus.id,
        "tenant_id" => hub.tenant_id,
        "hub_id" => hub.id,
        "load_type" => lt
      }
      end
      rows.each do |row|
        case row[:rate_basis]
        when 'PER_SHIPMENT'
          charge = {currency: row[:currency], value: row[:shipment], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
        when 'PER_CONTAINER'
          charge = {currency: row[:currency], value: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
        when 'PER_BILL'
          charge = {currency: row[:currency], value: row[:bill], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
        when 'PER_CBM'
          charge = {currency: row[:currency], value: row[:cbm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
        when 'PER_ITEM'
          charge = {currency: row[:currency], value: row[:item], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
        when 'PER_CBM_TON'
          charge = {currency: row[:currency], cbm: row[:cbm], ton: row[:ton], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
        when 'PER_CBM_KG'
          charge = {currency: row[:currency], cbm: row[:cbm], kg: row[:kg], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
        end
        hub_fees = local_charge_load_setter(hub_fees, charge, row[:load_type].downcase, row[:direction].downcase)
      end
      
      hub_fees.each do |k,v|
        lc_id = "#{hub.id}_#{hub.tenant_id}_load_type"
        update_item('localCharges', {"_id" => lc_id}, v)
      end
    end
  end

  def overwrite_air_schedules(params, user = current_user)
    old_ids = Schedule.pluck(:id)
    new_ids = []
    locations = {}
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    schedules = first_sheet.parse( from: 'FROM', to: 'TO', eta: 'ETA', etd: 'ETS')

    schedules.each do |row|
      row[:mode_of_transport] = "air"

      tenant = Tenant.find(current_user.tenant_id)
     
      tenant_vehicle = TenantVehicle.find_by(
          tenant_id: user.tenant_id, 
          mode_of_transport: row[:mode_of_transport]
        )
      startDate = row[:etd]
      endDate =  row[:eta]
      
      if locations[row[:from]] && locations[row[:to]]
        itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: row[:mode_of_transport], name: "#{locations[row[:from]].name} - #{locations[row[:to]].name}")
      
      else
        locations[row[:from]] = Location.find_by_name(row[:from])
        locations[row[:to]] = Location.find_by_name(row[:to])

        itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: row[:mode_of_transport], name: "#{locations[row[:from]].name} - #{locations[row[:to]].name}")
      end
      origin_hub_ids = locations[row[:from]].hubs_by_type(row[:mode_of_transport], user.tenant_id).ids
      destination_hub_ids = locations[row[:to]].hubs_by_type(row[:mode_of_transport], user.tenant_id).ids
      hub_ids = origin_hub_ids + destination_hub_ids

      stops_in_order = hub_ids.map.with_index { |h, i| itinerary.stops.find_or_create_by!(hub_id: h, index: i)  }
      stops = itinerary.stops.order(:index)
      
      if itinerary
        sched = itinerary.generate_schedules_from_sheet(stops, startDate, endDate, tenant_vehicle.vehicle_id)
      else
        raise "Route cannot be found!"
      end
    end
  end

  def overwrite_trucking_schedules(params, user = current_user)
    old_ids = Schedule.pluck(:id)
    new_ids = []
    locations = {}
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    schedules = first_sheet.parse(from: 'FROM', to: 'TO', eta: 'ETA', etd: 'ETS')

    schedules.each do |row|
      row[:mode_of_transport] = "trucking"

      tenant = Tenant.find(current_user.tenant_id)
     
      tenant_vehicle = TenantVehicle.find_by(
          tenant_id: user.tenant_id, 
          mode_of_transport: row[:mode_of_transport]
        )
      startDate = row[:etd]
      endDate =  row[:eta]
      
      if locations[row[:from]] && locations[row[:to]]
        itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: row[:mode_of_transport], name: "#{locations[row[:from]].name} - #{locations[row[:to]].name}")
      
      else
        locations[row[:from]] = Location.find_by_name(row[:from])
        locations[row[:to]] = Location.find_by_name(row[:to])

        itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: row[:mode_of_transport], name: "#{locations[row[:from]].name} - #{locations[row[:to]].name}")
      end
      origin_hub_ids = locations[row[:from]].hubs_by_type(row[:mode_of_transport], user.tenant_id).ids
      destination_hub_ids = locations[row[:to]].hubs_by_type(row[:mode_of_transport], user.tenant_id).ids
      hub_ids = origin_hub_ids + destination_hub_ids

      stops_in_order = hub_ids.map.with_index { |h, i| itinerary.stops.find_or_create_by!(hub_id: h, index: i)  }
      stops = itinerary.stops.order(:index)
      
      if itinerary
        sched = itinerary.generate_schedules_from_sheet(stops, startDate, endDate, tenant_vehicle.vehicle_id)
      else
        raise "Route cannot be found!"
      end
    end
  end

  def overwrite_vessel_schedules(params, user = current_user)
    locations = {}
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    schedules = first_sheet.parse(
      vessel: 'VESSEL', 
      call_sign: 'VOYAGE_CODE', 
      from: 'FROM', 
      to: 'TO', 
      eta: 'ETA', 
      etd: 'ETS')
    schedules.each do |row|
      row[:mode_of_transport] = "ocean"

      tenant = Tenant.find(current_user.tenant_id)
     
      tenant_vehicle = TenantVehicle.find_by(
          tenant_id: user.tenant_id, 
          mode_of_transport: row[:mode_of_transport]
        )
      startDate = row[:etd]
      endDate =  row[:eta]
      
      if locations[row[:from]] && locations[row[:to]]
        itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: row[:mode_of_transport], name: "#{locations[row[:from]].name} - #{locations[row[:to]].name}")
      else
        locations[row[:from]] = Location.find_by_name(row[:from])
        locations[row[:to]] = Location.find_by_name(row[:to])

        itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: row[:mode_of_transport], name: "#{locations[row[:from]].name} - #{locations[row[:to]].name}")
      end
      origin_hub_ids = locations[row[:from]].hubs_by_type(row[:mode_of_transport], user.tenant_id).ids
      destination_hub_ids = locations[row[:to]].hubs_by_type(row[:mode_of_transport], user.tenant_id).ids
      hub_ids = origin_hub_ids + destination_hub_ids

      stops_in_order = hub_ids.map.with_index { |h, i| itinerary.stops.find_or_create_by!(hub_id: h, index: i)  }
      stops = itinerary.stops.order(:index)
      
      if itinerary
        sched = itinerary.generate_schedules_from_sheet(stops, startDate, endDate, tenant_vehicle.vehicle_id)
      else
        raise "Route cannot be found!"
      end
    end
  end

  def overwrite_train_schedules(params, user = current_user)
    data_box = {}
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    schedules = first_sheet.parse(from: 'FROM', to: 'TO', eta: 'ETA', etd: 'ETD')

    schedules.each do |train_schedule|
      train_schedule[:mode_of_transport] = 'train'
      tenant = Tenant.find(current_user.tenant_id)
      
      tenant_vehicle = TenantVehicle.find_by(
          tenant_id: user.tenant_id, 
          mode_of_transport: train_schedule[:mode_of_transport]
        )
      startDate = train_schedule[:etd]
      endDate =  train_schedule[:eta]
      
      if locations[train_schedule[:from]] && locations[train_schedule[:to]]
        itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: train_schedule[:mode_of_transport], name: "#{locations[train_schedule[:from]].name} - #{locations[train_schedule[:to]].name}")
      
      else
        locations[train_schedule[:from]] = Location.find_by_name(train_schedule[:from])
        locations[train_schedule[:to]] = Location.find_by_name(train_schedule[:to])

        itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: train_schedule[:mode_of_transport], name: "#{locations[train_schedule[:from]].name} - #{locations[train_schedule[:to]].name}")
      end
      origin_hub_ids = locations[train_schedule[:from]].hubs_by_type(train_schedule[:mode_of_transport], user.tenant_id).ids
      destination_hub_ids = locations[train_schedule[:to]].hubs_by_type(train_schedule[:mode_of_transport], user.tenant_id).ids
      hub_ids = origin_hub_ids + destination_hub_ids

      stops_in_order = hub_ids.map.with_index { |h, i| itinerary.stops.find_or_create_by!(hub_id: h, index: i)  }
      stops = itinerary.stops.order(:index)
      
      if itinerary
        sched = itinerary.generate_schedules_from_sheet(stops, startDate, endDate, tenant_vehicle.vehicle_id)
      else
        raise "Route cannot be found!"
      end
    end
  end

  def overwrite_hubs(params, user = current_user)
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)

    hub_rows = first_sheet.parse( hub_status: 'STATUS', hub_type: 'TYPE', hub_name: 'NAME', hub_code: 'CODE', trucking_type: 'TRUCKING_METHOD', hub_operator: 'OPERATOR', latitude: 'LATITUDE', longitude: 'LONGITUDE', country: 'COUNTRY', geocoded_address: 'FULL_ADDRESS', hub_address_details: 'ADDRESS_DETAILS', photo: 'PHOTO')

    hub_type_name = {
      "ocean" => "Port",
      "air" => "Airport",
      "rail" => "Railway Station"
    }

    hub_rows.map do |hub_row|
      hub_row[:hub_type] = hub_row[:hub_type].downcase
      nexus = Location.find_or_create_by(
        name:          hub_row[:hub_name], 
        location_type: "nexus", 
        photo:         hub_row[:photo],
        latitude:      hub_row[:latitude], 
        longitude:     hub_row[:longitude],
        country:       hub_row[:country], 
        city:          hub_row[:hub_name]
      )
      location = Location.find_or_create_by(
        name:          hub_row[:hub_name], 
        latitude:      hub_row[:latitude], 
        longitude:     hub_row[:longitude], 
        photo:         hub_row[:photo], 
        country:       hub_row[:country], 
        city:          hub_row[:hub_name],
        geocoded_address: hub_row[:geocoded_address]
      )
      hub_code = hub_row[:hub_code] unless hub_row[:hub_code].blank?
      
      hub = nexus.hubs.find_or_create_by!(
        nexus_id:      nexus.id, 
        location_id:   location.id, 
        tenant_id:     user.tenant_id, 
        hub_type:      hub_row[:hub_type], 
        trucking_type: hub_row[:trucking_type], 
        latitude:      hub_row[:latitude], 
        longitude:     hub_row[:longitude], 
        name:          "#{nexus.name} #{hub_type_name[hub_row[:hub_type]]}", 
        photo:         hub_row[:photo]
      )
      hub.generate_hub_code!(user.tenant_id) unless hub.hub_code
      hub
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

  def overwrite_mongo_fcl_pricings(params, dedicated, user = current_user)
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
    new_hub_route_pricings = {}

    pricing_rows.each_with_index do |row, index|
      puts "load pricing row #{index}..."
      origin      = Location.find_by(name: row[:origin], location_type: 'nexus')
      destination = Location.find_by(name: row[:destination], location_type: 'nexus')
      route = Route.find_or_create_by!(name: "#{origin.name} - #{destination.name}", tenant_id: user.tenant_id, origin_nexus_id: origin.id, destination_nexus_id: destination.id)
      hubroute = HubRoute.create_from_route(route, row[:mot], user.tenant_id)

      vehicle_name = row[:vehicle_type] || "#{row[:mot]}_default"
      vehicle      = Vehicle.find_by(name: vehicle_name)

      cargo_classes = [
        'fcl_20f',
        'fcl_40f',
        'fcl_40f_hq',
        'lcl'
      ]
      row[:effective_date] = DateTime.now
      row[:expiration_date] = row[:effective_date] + 40.days
      hubroute.generate_weekly_schedules(row[:mot], row[:effective_date], row[:expiration_date], [1,5], 30, vehicle.id)

      lcl_obj = {
        BAS: {
          currency: row[:lcl_currency],
          rate: row[:lcl_rate_wm],
          min: row[:lcl_rate_min],
          rate_basis: 'PER_CBM'
        },
        HAS: {
          currency: row[:lcl_currency],
          rate: row[:lcl_heavy_weight_surcharge_wm],
          min: row[:lcl_heavy_weight_surcharge_min],
          rate_basis: 'PER_CBM'
        }
      }

      fcl_20f_obj = {
        BAS:{
          currency: row[:fcl_20_currency],
          rate: row[:fcl_20_rate],
          rate_basis: 'PER_CONTAINER'
        },
        HAS:{
          currency: row[:fcl_20_currency],
          rate: row[:fcl_20_heavy_weight_surcharge_wm],
          min: row[:fcl_20_heavy_weight_surcharge_min],
          rate_basis: 'PER_CONTAINER'
        }
      }

      fcl_40f_obj = {
        BAS:{
          currency: row[:fcl_40_currency],
          rate: row[:fcl_40_rate],
          rate_basis: 'PER_CONTAINER'
        },
        HAS:{
          currency: row[:fcl_40_currency],
          rate: row[:fcl_40_heavy_weight_surcharge_wm],
          min: row[:fcl_40_heavy_weight_surcharge_min],
          rate_basis: 'PER_CONTAINER'
        }
      }

      fcl_40f_hq_obj = {
        BAS:{
          currency: row[:fcl_40_hq_currency],
          rate: row[:fcl_40_hq_rate],
          rate_basis: 'PER_CONTAINER'
        },
        HAS:{
          currency: row[:fcl_40_hq_currency],
          rate: row[:fcl_40_hq_heavy_weight_surcharge_wm],
          min: row[:fcl_40_hq_heavy_weight_surcharge_min],
          rate_basis: 'PER_CONTAINER'
        }
      }

      price_obj = {
        "lcl"        => lcl_obj.to_h, 
        "fcl_20f"    => fcl_20f_obj.to_h, 
        "fcl_40f"    => fcl_40f_obj.to_h, 
        "fcl_40f_hq" => fcl_40f_hq_obj.to_h
      }

      cargo_classes.each do |cargo_class|
        uuid = SecureRandom.uuid
        transport_category_name = row[:cargo_type] || "any"
        transport_category = vehicle.transport_categories.find_by(
          name: transport_category_name, 
          cargo_class: cargo_class
        )

        pathKey = "#{stops_in_order[0].id}_#{stops_in_order.last.id}_#{transport_category.id}"
        priceKey = "#{stops_in_order[0].id}_#{stops_in_order.last.id}_#{transport_category.id}_#{user.tenant_id}_#{cargo_class}"
        
        pricing = { 
          data: price_obj[cargo_class], 
          _id: uuid,
          tenant_id: user.tenant_id
        }
        
        update_item_fn(mongo, 'pricings', {_id: "#{priceKey}"}, pricing)
        
        new_hub_route_pricings[pathKey] ||= {}
        if dedicated
          user_pricing = { pathKey => uuid }
          update_item_fn(mongo, 'userPricings', {_id: "#{user.id}"}, user_pricing)
          
          new_hub_route_pricings[pathKey]["#{user.id}"] = uuid
        else
          new_hub_route_pricings[pathKey]["open"]                  = uuid
          new_hub_route_pricings[pathKey]["hub_route_id"]          = hubroute.id
          new_hub_route_pricings[pathKey]["tenant_id"]             = user.tenant_id
          new_hub_route_pricings[pathKey]["route_id"]              = route.id
          new_hub_route_pricings[pathKey]["load_type"]              = cargo_class
          new_hub_route_pricings[pathKey]["transport_category_id"] = transport_category.id
        end
      end
    end

    new_hub_route_pricings.each do |key, value|
      update_hub_route_pricing(key, value)
    end
  end

  def overwrite_mongo_lcl_pricings(params, dedicated, user = current_user)
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
      ohc_currency: "OHC_CURRENCY",
      ohc_cbm: "OHC_CBM",
      ohc_ton: "OHC_TON",
      ohc_min: "OHC_MIN",
      lcls_currency: "LCLS_CURRENCY",
      lcl_service_cbm: "LCL_SERVICE_CBM",
      lcl_service_ton: "LCL_SERVICE_TON",
      lcl_service_min: "LCL_SERVICE_MIN",
      isps_currency: "ISPS_CURRENCY",
      isps: "ISPS",
      exp_currency: "EXP_CURRENCY",
      exp_declaration: "EXP_DECLARATION",
      exp_limit: "EXP_LIMIT",
      exp_extra: "EXP_XTRA",
      odf_currency: "ODF_CURRENCY",
      odf: "ODF",
      ls_currency: "LS_CURRENCY",
      liner_service_fee: "LINER_SERVICE_FEE",
      vgm_currency: "VGM_CURRENCY",
      vgm_fee: "VGM_FEE", 
      ddf_currency: "DDF_CURRENCY",
      ddf: "DDF",
      dhc_currency: "DHC_CURRENCY",
      dhc: "DHC",
      customs_currency: "CUSTOMS_CURRENCY",
      customs_clearance: "CUSTOMS_CLEARANCE",
      cfs_currency: "CFS_CURRENCY",
      cfs_terminal_charges: "CFS_TERMINAL_CHARGES",
    )
    new_pricings = []
    new_itinerary_pricings = {}

    pricing_rows.each_with_index do |row, index|
      puts "load pricing row #{index}..."
      tenant = user.tenant
      origin      = Location.find_by(name: row[:origin], location_type: 'nexus')
      destination = Location.find_by(name: row[:destination], location_type: 'nexus')
      origin_hub_ids = origin.hubs_by_type(row[:mot], user.tenant_id).ids
      destination_hub_ids = destination.hubs_by_type(row[:mot], user.tenant_id).ids
      hub_ids = origin_hub_ids + destination_hub_ids

      vehicle_name = row[:vehicle_type] || "#{row[:mot]}_default"
      vehicle      = Vehicle.find_by(name: vehicle_name)
      # itinerary = Itinerary.find_or_create_by_hubs(hub_ids, user.tenant_id, row[:mot], vehicle.id, "#{origin.name} - #{destination.name}")
      itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: row[:mot], name: "#{origin.name} - #{destination.name}")
      stops_in_order = hub_ids.map.with_index { |h, i| itinerary.stops.find_or_create_by!(hub_id: h, index: i)  }
      cargo_classes = [
        'lcl'
      ]
      steps_in_order = []
      stops_in_order.length.times do 
        steps_in_order << 30
      end
      row[:effective_date] = DateTime.now
      row[:expiration_date] = row[:effective_date] + 40.days
      itinerary.generate_weekly_schedules(
        stops_in_order,
        steps_in_order,
        row[:effective_date], 
        row[:expiration_date], 
        [1, 5],
        vehicle.id
      )

      lcl_obj = {
        BAS: {
          currency: row[:lcl_currency],
          rate: row[:lcl_rate_wm],
          min: row[:lcl_rate_min],
          rate_basis: 'PER_CBM'
        },
        HAS: {
          currency: row[:lcl_currency],
          rate: row[:lcl_heavy_weight_surcharge_wm],
          min: row[:lcl_heavy_weight_surcharge_min],
          rate_basis: 'PER_CBM'
        }
      }
      destination_import_fees = {
        DHC: {
          currency: row[:dhc_currency],
          rate: row[:dhc],
          rate_basis: 'PER_ITEM'
          # cbm: row[:dhc_cbm],
          # ton: row[:dhc_ton],
          # min: row[:dhc_min],
          # rate_basis: 'PER_CBM_TON'
        },
        LCLS: {
          currency: row[:lcls_currency],
          cbm: row[:lcl_service_cbm],
          ton: row[:lcl_service_ton],
          min: row[:lcl_service_min],
          rate_basis: 'PER_CBM_TON'
        },
        ISPS: {
          currency: row[:isps_currency],
          rate: row[:isps],
          rate_basis: 'PER_SHIPMENT'
        },
        DDF: {
          currency: row[:ddf_currency],
          rate: row[:ddf],
          rate_basis: 'PER_SHIPMENT'
        }
      }
      origin_export_fees = {
         OHC: {
          currency: row[:ohc_currency],
          cbm: row[:ohc_cbm],
          ton: row[:ohc_ton],
          min: row[:ohc_min],
          rate_basis: 'PER_CBM_TON'
        },
        CFS: {
          currency: row[:cfs_currency],
          rate: row[:cfs_terminal_charges],
          rate_basis: 'PER_CBM'
        },
        LCLS: {
          currency: row[:lcls_currency],
          cbm: row[:lcl_service_cbm],
          ton: row[:lcl_service_ton],
          min: row[:lcl_service_min],
          rate_basis: 'PER_CBM_TON'
        },
        ISPS: {
          currency: row[:isps_currency],
          rate: row[:isps],
          rate_basis: 'PER_SHIPMENT'
        },
        ODF: {
          currency: row[:odf_currency],
          rate: row[:odf],
          rate_basis: 'PER_SHIPMENT'
        }
      }
      customsObj = {
        export:{ 
           EXP: {currency: row[:exp_currency],
          fee: row[:exp_declaration],
          limit: row[:exp_limit],
          extra: row[:exp_extra],
          rate_basis: 'PER_BILL'
        }
        },
        import:{ 
          IMP: {currency: row[:exp_currency],
          fee: row[:exp_declaration],
          limit: row[:exp_limit],
          extra: row[:exp_extra],
          rate_basis: 'PER_BILL'
        }
        },
        load_type: 'lcl',
        tenant_id: user.tenant_id
      }
      price_obj = {"lcl" =>lcl_obj.to_h}
      customsObj[:nexus_id] = origin.id
      origin_charge_key = "#{origin.id}_#{user.tenant_id}_lcl"
      destination_charge_key = "#{destination.id}_#{user.tenant_id}_lcl"
      update_item('customsFees', {_id: "#{origin_charge_key}"}, customsObj)
      customsObj[:nexus_id] = destination.id
      update_item('customsFees', {_id: "#{destination_charge_key}"}, customsObj)
      update_item('localCharges', {"_id" => origin_charge_key}, {"export" => origin_export_fees, "tenant_id" => user.tenant_id, nexus_id: origin.id, load_type: 'lcl'})
      update_item('localCharges', {"_id" => destination_charge_key}, {"import" => destination_import_fees, "tenant_id" => user.tenant_id, nexus_id: destination.id, load_type: 'lcl'})
      if dedicated
        cargo_classes.each do |cargo_class|
          uuid = SecureRandom.uuid

          transport_category_name = row[:cargo_type] || "any"
          transport_category = vehicle.transport_categories.find_by(
            name: transport_category_name, 
            cargo_class: cargo_class
          )
          
          pathKey  = "#{stops_in_order[0].id}_#{stops_in_order.last.id}_#{transport_category.id}"
          priceKey = "#{stops_in_order[0].id}_#{stops_in_order.last.id}_#{transport_category.id}_#{user.tenant_id}_#{cargo_class}_#{user.id}"
          
          pricing = { 
            data:      price_obj[cargo_class], 
            _id:       priceKey,
            tenant_id: user.tenant_id,
            load_type: cargo_class
          }
          
          update_item_fn(mongo, 'pricings', {_id: "#{priceKey}"}, pricing)
          
          user_pricing = { pathKey => priceKey}
          
          update_item_fn(mongo, 'customsFees', {_id: "#{priceKey}"}, customsObj)
          update_item_fn(mongo, 'userPricings', {_id: "#{user.id}"}, user_pricing)
          
          new_itinerary_pricings[pathKey] ||= {}
          new_itinerary_pricings[pathKey]["#{user.id}"] = priceKey
        end
      else
        cargo_classes.each do |cargo_class|
          uuid = SecureRandom.uuid

          transport_category_name = row[:cargo_type] || "any"
          transport_category = vehicle.transport_categories.find_by(
            name: transport_category_name, 
            cargo_class: cargo_class
          )

          pathKey = "#{stops_in_order[0].id}_#{stops_in_order.last.id}_#{transport_category.id}"
          priceKey = "#{stops_in_order[0].id}_#{stops_in_order.last.id}_#{transport_category.id}_#{user.tenant_id}_#{cargo_class}"

          pricing = { 
            data:         price_obj[cargo_class], 
            _id:          priceKey,
            itinerary_id: itinerary.id,
            tenant_id:    user.tenant_id
          }

          update_item_fn(mongo, 'pricings', {_id: "#{priceKey}"}, pricing)
          update_item_fn(mongo, 'customsFees', {_id: "#{priceKey}"}, customsObj)

          new_itinerary_pricings[pathKey] ||= {}
          new_itinerary_pricings[pathKey]["open"]                  = priceKey
          new_itinerary_pricings[pathKey]["tenant_id"]             = user.tenant_id
          new_itinerary_pricings[pathKey]["itinerary_id"]          = itinerary.id
          new_itinerary_pricings[pathKey]["transport_category_id"] = transport_category.id
        end
      end
    end

    new_itinerary_pricings.each do |key, value|
      update_itinerary_pricing(key, value)
    end
  end
  def overwrite_customs(params, mot, user = current_user)
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
      ohc_currency: "OHC_CURRENCY",
      ohc_cbm: "OHC_CBM",
      ohc_ton: "OHC_TON",
      ohc_min: "OHC_MIN",
      lcls_currency: "LCLS_CURRENCY",
      lcl_service_cbm: "LCL_SERVICE_CBM",
      lcl_service_ton: "LCL_SERVICE_TON",
      lcl_service_min: "LCL_SERVICE_MIN",
      isps_currency: "ISPS_CURRENCY",
      isps: "ISPS",
      exp_currency: "EXP_CURRENCY",
      exp_declaration: "EXP_DECLARATION",
      exp_limit: "EXP_LIMIT",
      exp_extra: "EXP_XTRA",
      odf_currency: "ODF_CURRENCY",
      odf: "ODF",
      ls_currency: "LS_CURRENCY",
      liner_service_fee: "LINER_SERVICE_FEE",
      vgm_currency: "VGM_CURRENCY",
      vgm_fee: "VGM_FEE", 
      ddf_currency: "DDF_CURRENCY",
      ddf: "DDF",
      dhc_currency: "DHC_CURRENCY",
      dhc: "DHC",
      customs_currency: "CUSTOMS_CURRENCY",
      customs_clearance: "CUSTOMS_CLEARANCE",
      cfs_currency: "CFS_CURRENCY",
      cfs_terminal_charges: "CFS_TERMINAL_CHARGES",
    )
    new_pricings = []
    new_itinerary_pricings = {}

    pricing_rows.each_with_index do |row, index|
      puts "load pricing row #{index}..."
      tenant = user.tenant
      origin      = Location.find_by(name: row[:origin], location_type: 'nexus')
      destination = Location.find_by(name: row[:destination], location_type: 'nexus')
      origin_hub_ids = origin.hubs_by_type(mot, user.tenant_id).ids
      destination_hub_ids = destination.hubs_by_type(mot, user.tenant_id).ids
      hub_ids = origin_hub_ids + destination_hub_ids

      vehicle_name = row[:vehicle_type] || "#{mot}_default"
      vehicle      = Vehicle.find_by(name: vehicle_name)
      # itinerary = Itinerary.find_or_create_by_hubs(hub_ids, user.tenant_id, mot, vehicle.id, "#{origin.name} - #{destination.name}")
      itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: mot, name: "#{origin.name} - #{destination.name}")
      stops_in_order = hub_ids.map.with_index { |h, i| itinerary.stops.find_or_create_by!(hub_id: h, index: i)  }
      cargo_classes = [
        'lcl'
      ]
      steps_in_order = []
      stops_in_order.length.times do 
        steps_in_order << 30
      end
      row[:effective_date] = DateTime.now
      row[:expiration_date] = row[:effective_date] + 40.days

      lcl_obj = {
        BAS: {
          currency: row[:lcl_currency],
          rate: row[:lcl_rate_wm],
          min: row[:lcl_rate_min],
          rate_basis: 'PER_CBM'
        },
        HAS: {
          currency: row[:lcl_currency],
          rate: row[:lcl_heavy_weight_surcharge_wm],
          min: row[:lcl_heavy_weight_surcharge_min],
          rate_basis: 'PER_CBM'
        }
      }
      destination_import_fees = {
        DHC: {
          currency: row[:dhc_currency],
          rate: row[:dhc],
          rate_basis: 'PER_ITEM'
          # cbm: row[:dhc_cbm],
          # ton: row[:dhc_ton],
          # min: row[:dhc_min],
          # rate_basis: 'PER_CBM_TON'
        },
        LCLS: {
          currency: row[:lcls_currency],
          cbm: row[:lcl_service_cbm],
          ton: row[:lcl_service_ton],
          min: row[:lcl_service_min],
          rate_basis: 'PER_CBM_TON'
        },
        ISPS: {
          currency: row[:isps_currency],
          rate: row[:isps],
          rate_basis: 'PER_SHIPMENT'
        },
        DDF: {
          currency: row[:ddf_currency],
          rate: row[:ddf],
          rate_basis: 'PER_SHIPMENT'
        }
      }
      origin_export_fees = {
         OHC: {
          currency: row[:ohc_currency],
          cbm: row[:ohc_cbm],
          ton: row[:ohc_ton],
          min: row[:ohc_min],
          rate_basis: 'PER_CBM_TON'
        },
        CFS: {
          currency: row[:cfs_currency],
          rate: row[:cfs_terminal_charges],
          rate_basis: 'PER_CBM'
        },
        LCLS: {
          currency: row[:lcls_currency],
          cbm: row[:lcl_service_cbm],
          ton: row[:lcl_service_ton],
          min: row[:lcl_service_min],
          rate_basis: 'PER_CBM_TON'
        },
        ISPS: {
          currency: row[:isps_currency],
          rate: row[:isps],
          rate_basis: 'PER_SHIPMENT'
        },
        ODF: {
          currency: row[:odf_currency],
          rate: row[:odf],
          rate_basis: 'PER_SHIPMENT'
        }
      }
      customsObj = {
        export:{ 
           EXP: {currency: row[:exp_currency],
          fee: row[:exp_declaration],
          limit: row[:exp_limit],
          extra: row[:exp_extra],
          rate_basis: 'PER_BILL'
        }
        },
        import:{ 
          IMP: {currency: row[:exp_currency],
          fee: row[:exp_declaration],
          limit: row[:exp_limit],
          extra: row[:exp_extra],
          rate_basis: 'PER_BILL'
        }
        },
        load_type: 'lcl',
        tenant_id: user.tenant_id
      }
      price_obj = {"lcl" =>lcl_obj.to_h}
      customsObj[:nexus_id] = origin.id
      origin_charge_key = "#{origin_hub_ids.first}_#{user.tenant_id}_lcl"
      destination_charge_key = "#{destination_hub_ids.first}_#{user.tenant_id}_lcl"
      update_item('customsFees', {_id: "#{origin_charge_key}"}, customsObj)
      customsObj[:nexus_id] = destination.id
      update_item('customsFees', {_id: "#{destination_charge_key}"}, customsObj)
      update_item('localCharges', {"_id" => origin_charge_key}, {"export" => origin_export_fees, "tenant_id" => user.tenant_id, hub_id: origin_hub_ids.first, nexus_id: origin.id, load_type: 'lcl', mode_of_transport: mot})
      update_item('localCharges', {"_id" => destination_charge_key}, {"import" => destination_import_fees, "tenant_id" => user.tenant_id, hub_id: destination_hub_ids.first, nexus_id: destination.id, load_type: 'lcl', mode_of_transport: mot})
     
    end

  end
  def overwrite_mongo_maersk_fcl_pricings(params, dedicated, user = current_user)
    mongo = get_client
    terms = {
      "BAS" => "Basic Ocean Freight",
      "HAS" => "HEAVY Ocean Freight",
      "CFD" => "Congestion Fee Destination",
      "CFO" => "Congestion Fee Origin",
      "DDF" => "Documentation fee - Destination",
      "DHC" => "Terminal Handling Service - Destination",
      "DPA" => "Arbitrary - Destination",
      "ERS" => "Emergency Risk Surcharge",
      "EXP" => "Export Service",
      "IHE" => "Inland Haulage Export",
      "IMP" => "Import Service",
      "LSS" => "Low Sulphur Surcharge",
        
      "ODF" => "Documentation Fee Origin",
      "OHC" => "Terminal Handling Service - Origin",
      "OPA" => "Arbitrary - Origin",
        
      "PSS" => "Peak Season Surcharge",
      "SBF" => "Standard Bunker Adjustment Factor",

      "SOC" => "Shipper Owned container",
      "NOR" => "Non Operating Refer container",
      "EMPTY" => "Empty Container",

      "CY" =>  "Container Yard",
      "SD" => "Store Door",

      "20DRY" => "20 Dry container",
      "40DRY" => "40 Dry container",
      "40HDRY"  => "40 High Cube Dry Container",
      "45HDRY"  => "45 High Cube Dry Container"
    }
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    pricing_rows = first_sheet.parse(
      receipt: 'RECEIPT',
      effective_date: 'EFFECTIVE_DATE',
      expiration_date: 'EXPIRY_DATE',
      origin: 'RECEIPT',
      cargo_type: 'COMMODITY_NAME',
      destination: 'DELIVERY',
      charge: 'CHARGE',
      inclusive_surcharge: 'INCLUSIVE_SURCHARGE',
      service_code: 'SERVICE_CODE',
      rate_basis: 'RATE_BASIS',
      fcl_20_rate: '20DRY',
      fcl_40_rate: '40DRY',
      fcl_40_hq_rate: '40HDRY',
      fcl_45_hq_rate: '45HDRY',
    )
    new_hub_route_pricings = {}
    new_pricings_aux_data = {}
    vehicle = Vehicle.find_by_name("ocean_default")
    new_pricings = {}

    pricing_rows.each_with_index do |row, index|
      row[:mot] = 'ocean'
      puts "load pricing row #{index}..."
      pricing_key = "#{row[:origin].gsub(/\s+/, "").gsub(/,+/, "")}_#{row[:destination].gsub(/\s+/, "").gsub(/,+/, "")}"
       
      if !new_pricings[pricing_key]
        new_pricings[pricing_key] = {
          "data" => {},
          "cargo_classes" => {
            "fcl_20f" => {},
            "fcl_40f" => {},
            "fcl_40f_hq" => {},
            "fcl_45f_hq" => {}
          }
        }
        tenant = user.tenant
        origin = Location.from_short_name(row[:origin], 'nexus')
        sleep(1)
        destination = Location.from_short_name(row[:destination], 'nexus')
        sleep(1)
        origin_hub_ids = origin.hubs_by_type_seeder(row[:mot], user.tenant_id).ids
        destination_hub_ids = destination.hubs_by_type_seeder(row[:mot], user.tenant_id).ids
        hub_ids = origin_hub_ids + destination_hub_ids
        vehicle_name = row[:vehicle_type] || "#{row[:mot]}_default"
        vehicle      = Vehicle.find_by(name: vehicle_name)
        # itinerary = Itinerary.find_or_create_by_hubs(hub_ids, user.tenant_id, row[:mot], vehicle.id, "#{origin.name} - #{destination.name}")
        itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: row[:mot], name: "#{origin.name} - #{destination.name}")
      
        new_pricings_aux_data[pricing_key] = {
          itinerary:       itinerary,
          hub_ids:         hub_ids
        }
        new_pricings[pricing_key]["data"] = {
          "itinerary_id"            => itinerary.id,
          "service_code"        => row[:service_code],
          "inclusive_surcharge" => row[:inclusive_surcharge]
        }
      end 

      cargo_classes = [
        'fcl_20f',
        'fcl_40f',
        'fcl_40f_hq'
      ]
      new_pricings_aux_data[pricing_key][:stops_in_order] = new_pricings_aux_data[pricing_key][:hub_ids].map.with_index { |h, i| new_pricings_aux_data[pricing_key][:itinerary].stops.find_or_create_by!(hub_id: h, index: i)  }
      steps_in_order = []
      new_pricings_aux_data[pricing_key][:stops_in_order].length.times do 
        steps_in_order << 30
      end
      row[:effective_date] = DateTime.now
      row[:expiration_date] = row[:effective_date] + 40.days
      new_pricings_aux_data[pricing_key][:itinerary].generate_weekly_schedules(
        new_pricings_aux_data[pricing_key][:stops_in_order],
        steps_in_order,
        row[:effective_date], 
        row[:expiration_date], 
        [1, 5],
        vehicle.id
      )
      cargo_type = row[:cargo_type] == 'FAK' ? nil : row[:cargo_type]
      new_pricings_aux_data[pricing_key][:cargo_type] = cargo_type

      new_pricings[pricing_key]["cargo_classes"].each do |cargo_class, cargo_class_prices|
        cargo_class_prices[row[:charge]] = price_split(row[:rate_basis], row[rate_key(cargo_class)])
      end
    end

    new_pricings.each do |pricing_key, pricing|
      pricing["cargo_classes"].each do |cargo_class, cargo_class_prices|
        next if cargo_class == 'fcl_45f_hq'

        cargo_type = new_pricings_aux_data[:cargo_type]
        transport_category_name = cargo_type || "any"
        transport_category = vehicle.transport_categories.find_by(
          name: transport_category_name, 
          cargo_class: cargo_class
        )

        pricing_data = pricing["data"]
        pricing_data["data"] = cargo_class_prices
        
        uuid = SecureRandom.uuid
        pathKey = "#{new_pricings_aux_data[pricing_key][:stops_in_order][0].id}_#{new_pricings_aux_data[pricing_key][:stops_in_order].last.id}_#{transport_category.id}"
        priceKey = "#{new_pricings_aux_data[pricing_key][:stops_in_order][0].id}_#{new_pricings_aux_data[pricing_key][:stops_in_order].last.id}_#{transport_category.id}_#{user.tenant_id}_#{cargo_class}"
        # pricing_data[:_id] = priceKey;
        pricing_data[:tenant_id] = user.tenant_id
        pricing_data[:load_type] = cargo_class
        if dedicated
          priceKey += "_#{user.id}"
          user_pricing = { pathKey => priceKey }

          update_item_fn(mongo, 'pricings', {_id: priceKey}, pricing_data)
          update_item_fn(mongo, 'userPricings', {_id: "#{user.id}"}, user_pricing)
          
          new_hub_route_pricings[pathKey] ||= {}
          new_hub_route_pricings[pathKey]["#{user.id}"] = priceKey
          new_hub_route_pricings[pathKey]["itinerary_id"]          = new_pricings_aux_data[pricing_key][:itinerary].id
          new_hub_route_pricings[pathKey]["tenant_id"]             = user.tenant_id
          new_hub_route_pricings[pathKey]["transport_category_id"] = transport_category.id
        else
          
          update_item_fn(mongo, 'pricings', {_id: priceKey}, pricing_data)

          new_hub_route_pricings[pathKey] ||= {}
          new_hub_route_pricings[pathKey]["open"]                  = priceKey
          new_hub_route_pricings[pathKey]["itinerary_id"]          = new_pricings_aux_data[pricing_key][:itinerary].id
          new_hub_route_pricings[pathKey]["tenant_id"]             = user.tenant_id
          new_hub_route_pricings[pathKey]["transport_category_id"] = transport_category.id
        end
      end
    end
    new_hub_route_pricings.each do |key, value|
      update_itinerary_pricing(key, value)
    end
  end

  def price_split(basis, string)
    vals = string.split(' ')
    return {
      "currency" => vals[1],
      "rate" => vals[0].to_i,
      "rate_basis" => basis
    }
  end

  def rate_key(cargo_class)
    base_str = cargo_class.dup
    base_str.slice! cargo_class.rindex("f")
    "#{base_str}_rate".to_sym
  end

  def local_charge_load_setter(all_charges, charge, load_type, direction)
    if load_type === 'fcl'
      ['fcl_20', 'fcl_40', 'fcl_40hq'].each do |lt|
        all_charges[lt][direction][charge[:key]] = charge
      end
    else
      all_charges[load_type][direction][charge[:key]] = charge
    end
    return all_charges
  end
end
