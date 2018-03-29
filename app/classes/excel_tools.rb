module ExcelTools
  include ImageTools
  include MongoTools
  include PricingTools

  def overwrite_zipcode_weight_trucking_rates(params, user = current_user, direction)
    # old_trucking_ids = nil
    # new_trucking_ids = []
    mongo = get_client
    stats = {
      type: 'trucking',
      trucking_hubs: {
        number_updated: 0,
        number_created: 0
      },
      trucking_queries: {
        number_updated: 0,
        number_created: 0
      },
      trucking_pricings: {
        number_updated: 0,
        number_created: 0
      }
    }
    results = {
      trucking_hubs: [],
      trucking_queries: [],
      trucking_pricings: []
    }
    defaults = []
    load_type = "lcl"
    new_trucking_pricings_array = []
    new_trucking_hubs_array = []
    new_trucking_queries_array = []
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
        # 
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
          if  direction == 'export'
            tmp[:fees][:congestion] = {
              value: 15,
              rate_basis: 'PER_ITEM',
              currency: currency_row[3]
            }
          end
          if  direction == 'import'
            tmp[:fees][:congestion] = {
              value: 15,
              rate_basis: 'PER_ITEM',
              currency: currency_row[3]
            }
          end
          tmp[:direction] = direction
          tmp[:type] = "default"
          tmp[:_id] = SecureRandom.uuid
          tmp[:trucking_hub_id] = trucking_table_id
          tmp[:trucking_query_id] = ntp[:_id]
          truckingPricings.push(tmp)
          results[:trucking_pricings] << tmp
          stats[:trucking_pricings][:number_updated] += 1
          # 
        end
        truckingQueries.push(ntp)
        results[:trucking_queries] << ntp
        stats[:trucking_queries][:number_updated] += 1
      end
      # 
      truckingQueries.each do |k|
        # update_item_fn(mongo,  'truckingQueries', {_id: k[:_id]}, k)
        new_trucking_queries_array << {
            :update_one => {
              :filter => {
                _id: "#{k[:_id]}"
              },
              :update => {
                "$set" => k
              }, :upsert => true
            }
          }
      end
      truckingPricings.each do |k|
        # update_item_fn(mongo,  'truckingPricings', {_id: k[:_id]}, k)
        new_trucking_pricings_array << {
            :update_one => {
              :filter => {
                _id: "#{k[:_id]}"
              },
              :update => {
                "$set" => k
              }, :upsert => true
            }
          }
      end
      new_trucking_hub_obj = {
        modifier: "zipcode", 
        tenant_id: user.tenant_id, 
        nexus_id: nexus.id, 
        load_type: 'lcl',
        load_meterage: {
          active: true,
          height_limit: 130,
          ratio: 1850
        },
        cbm_ratio: 333
      }
      results[:trucking_hubs] << new_trucking_hub_obj
      stats[:trucking_hubs][:number_updated] += 1
      # update_item_fn(mongo, 'truckingHubs', {_id: trucking_table_id}, {modifier: "zipcode", tenant_id: user.tenant_id, nexus_id: nexus.id, load_type: 'lcl'})
      new_trucking_hubs_array << {
            :update_one => {
              :filter => {
                _id: "#{trucking_table_id}"
              },
              :update => {
                "$set" => new_trucking_hub_obj
              }, :upsert => true
            }
          }
    end
    mongo["truckingHubs"].bulk_write(new_trucking_hubs_array)
    mongo["truckingPricings"].bulk_write(new_trucking_pricings_array)
    mongo["truckingQueries"].bulk_write(new_trucking_queries_array)
    return {results: results, stats: stats}
  end
  def handle_zipcode_sections(rows, user, direction, hub_id, courier_name, load_type, defaults, weight_min_row, meta)
    hub = Hub.find(hub_id)
    courier = Courier.find_or_create_by(name: courier_name)
    rows.each do |row_data|
      zip_code_range_array = row_data.shift.split(" - ")
        zip_code_range = (zip_code_range_array[0].to_i...zip_code_range_array[1].to_i)
        
        row_min_value = row_data.shift
        
        trucking_pricing = TruckingPricing.new(
          export: { table: [] },
          import: { table: [] },
          load_type: meta[:load_type],
          load_meterage: {
            ratio:  meta[:load_meterage_ratio],
            height_limit: 130
          },
          cbm_ratio:  meta[:cbm_ratio],
          courier: courier,
          modifier:  meta[:modifier],
          truck_type: 'default'
        )
        trucking_pricing[direction]["table"] = row_data.map.with_index do |val, i|
          defaults[i].clone.merge({
            min_value: [weight_min_row[i], row_min_value].max,
            fees: {
              base_rate: {
                value: val,
                rate_basis: 'PER_X_KG',
                currency: meta[:currency],
                base: 100
              },
              congestion: {
                value: 15,
                rate_basis: 'PER_SHIPMENT',
                currency: meta[:currency]
              }
            }
          })
        end
        trucking_pricing_should_update = nil
        zip_code_range.each do |zipcode|
          p zipcode
          trucking_destination = TruckingDestination.find_by!(zipcode: zipcode, country_code: 'SE')
          trucking_pricing_ids = TruckingPricing.where(
            load_type: load_type,
            truck_type: 'default',
            load_meterage: {
              ratio: meta[:load_meterage_ratio],
              height_limit: 130
            },
            modifier: meta[:modifier]
          ).ids
          hub_trucking = HubTrucking.where(              
            trucking_destination: trucking_destination,
            trucking_pricing_id: trucking_pricing_ids,
            hub_id: hub_id
          ).first

          if hub_trucking.nil?
            trucking_pricing.save!
            HubTrucking.create(
              trucking_destination: trucking_destination,
              trucking_pricing: trucking_pricing,
              hub_id: hub_id
            )
          else
            trucking_pricing_should_update = hub_trucking.trucking_pricing
          end
        end
        
        trucking_pricing_should_update.try(:update,
          direction => { "table" => trucking_pricing[direction]["table"] }
        )

      #  zip_code_range_array = row_data.shift.split(" - ")
       
      #   row_min_value = row_data.shift
      #   zip_codes = []
      #   hub_truckings = []
      #   tmp_zip = zip_code_range_array[0].to_i
      #   while tmp_zip <= zip_code_range_array[1].to_i
      #     td = TruckingDestination.find_by!(zipcode: tmp_zip, country_code: 'SE')
      #     zip_codes << td
      #     hub_truckings << HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id)
      #     tmp_zip += 1
          
      #   end

      #   if hub_truckings[0].trucking_pricing_id
      #     trucking_pricing = hub_truckings[0].trucking_pricing
      #   else
      #     trucking_pricing = courier.trucking_pricings.create!(export: { table: []}, import: { table: []}, load_type: load_type)
      #   end
      #  p trucking_pricing.id
      #  byebug
      #   row_data.each_with_index do |val, index|
      #     tmp = defaults[index].clone
      #     if row_min_value < weight_min_row[index]
      #       min_value = weight_min_row[index]
      #     else
      #       min_value = row_min_value
      #     end
      #     tmp[:min_value] = min_value
      #     tmp[:fees] = {  
      #       base_rate: {
      #         value: val,
      #         rate_basis: 'PER_X_KG',
      #         currency: currency,
      #         base: 100
      #       }
            
      #     }

      #       tmp[:fees][:congestion] = {
      #         value: 15,
      #         rate_basis: 'PER_ITEM',
      #         currency: currency
      #       }

      #     tmp[:direction] = direction
      #     tmp[:type] = "default"
      #     trucking_pricing["load_meterage"] = {
      #       ratio: 1850,
      #       height_limit: 130
      #     }
      #     trucking_pricing[:modifier] = 'kg'
      #     trucking_pricing[direction]["table"].push(tmp)
      #     trucking_pricing.save!
      #     hub_truckings.each do |ht|
      #       ht.trucking_pricing_id = trucking_pricing.id
      #       ht.save!
      #     end
      #   end
        
      end
  end
  def split_zip_code_sections(params, user = current_user, hub_id, courier_name, direction)
    defaults = []
    test_array = []
    load_type = "cargo_item"
    no_of_jobs = 10
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      num_rows = first_sheet.last_row
      rows_per_job = ((num_rows - 4)/no_of_jobs).to_i

      rows_for_job = []
      (0...no_of_jobs-1).each do |index|
        tmp_array = []
        start_row = 4 + (index * rows_per_job)
        end_row = 3 + ((index + 1) * rows_per_job)
        (start_row...end_row).each do |row_no|
          tmp_array.push(first_sheet.row(row_no))
        end
        
        rows_for_job << tmp_array
      end
      meta_row = first_sheet.row(1)
      currency = meta_row[3]
      base = meta_row[11]
      modifier = meta_row[9]
      cbm_ratio = meta_row[7]
      load_meterage_ratio = meta_row[5]
      header_row = first_sheet.row(2)
      header_row.shift
      header_row.shift
      weight_min_row = first_sheet.row(3)
      weight_min_row.shift
      weight_min_row.shift
      
      header_row.each do |cell|
        min_max_arr = cell.split(" - ")
        defaults.push({min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil})
      end
      
      rows_for_job.each do |rfj|
        job_id = SecureRandom.uuid
       update_item("jobs", {_id: job_id}, {completed: false, created: DateTime.now})
        worker_obj = {
          defaults: defaults,
          weight_min_row: weight_min_row,
          rows_for_job: rfj.clone(),
          hub_id: hub_id,
          courier_name: courier_name,
          load_type: load_type,
          direction: direction,
          user_id: user.id,
          job_id: job_id,
          meta: {
            load_type: load_type,
            currency: currency,
            cbm_ratio: cbm_ratio,
            load_meterage_ratio: load_meterage_ratio,
            base: base
          }
        }
        ExcelWorker.perform_async(worker_obj)
        
      end
    end
    # handle_zipcode_sections(test_array[0][:rows_for_job], user, test_array[0][:direction], test_array[0][:hub_id], test_array[0][:courier_name], test_array[0][:load_type], test_array[0][:defaults], test_array[0][:weight_min_row], test_array[0][:currency])
  end
   def overwrite_zipcode_trucking_rates_by_hub(params, user = current_user, hub_id, courier_name, direction)
    # old_trucking_ids = nil
    # new_trucking_ids = []
    mongo = get_client
    stats = {
      type: 'trucking',
      trucking_hubs: {
        number_updated: 0,
        number_created: 0
      },
      trucking_queries: {
        number_updated: 0,
        number_created: 0
      },
      trucking_pricings: {
        number_updated: 0,
        number_created: 0
      }
    }
    results = {
      trucking_hubs: [],
      trucking_queries: [],
      trucking_pricings: []
    }
    courier = Courier.find_or_create_by(name: courier_name)
    defaults = []
    load_type = "cargo_item"
    new_trucking_pricings_array = []
    new_trucking_hubs_array = []
    new_trucking_queries_array = []
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      num_rows = first_sheet.last_row
      

      hub = Hub.find(hub_id)
      nexus = hub.nexus

      currency_row = first_sheet.row(1)
      hubs = nexus.hubs
      header_row = first_sheet.row(2)
      header_row.shift
      header_row.shift
      weight_min_row = first_sheet.row(3)
      weight_min_row.shift
      weight_min_row.shift
      
      header_row.each do |cell|
        min_max_arr = cell.split(" - ")
        defaults.push({min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil})
      end

      (4..num_rows).each do |line|
        # 
        row_data = first_sheet.row(line)
        zip_code_range_array = row_data.shift.split(" - ")
        # zip_code_range = (zip_code_range_array[0].to_i..zip_code_range_array[1].to_i)
        row_min_value = row_data.shift
        # ntp = TruckingPricing.new(currency: currency_row[3], tenant_id: user.tenant_id, nexus_id: nexus.id, lower_zip: zip_code_range_array[0].to_i, upper_zip: zip_code_range_array[1].to_i)
        zip_codes = []
        hub_truckings = []
        tmp_zip = zip_code_range_array[0].to_i
        while tmp_zip <= zip_code_range_array[1].to_i
          td = TruckingDestination.find_by!(zipcode: tmp_zip, country_code: 'SE')
          zip_codes << td
          hub_truckings << HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id)
          tmp_zip += 1
          p tmp_zip
        end

        if hub_truckings[0].trucking_pricing_id
          trucking_pricing = hub_truckings[0].trucking_pricing
        else
          trucking_pricing = courier.trucking_pricings.create!(export: { table: []}, import: { table: []}, load_type: load_type)
        end
       
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
          if  direction == 'export'
            tmp[:fees][:congestion] = {
              value: 15,
              rate_basis: 'PER_ITEM',
              currency: currency_row[3]
            }
          end
          if  direction == 'import'
            tmp[:fees][:congestion] = {
              value: 15,
              rate_basis: 'PER_ITEM',
              currency: currency_row[3]
            }
          end
          tmp[:direction] = direction
          tmp[:type] = "default"
          trucking_pricing["load_meterage"] = {
            ratio: 1950,
            height_limit: 130
          }
          trucking_pricing[:modifier] = 'kg'
          trucking_pricing[direction]["table"].push(tmp)
          results[:trucking_pricings] << tmp
          stats[:trucking_pricings][:number_updated] += 1
          trucking_pricing.save!
          hub_truckings.each do |ht|
            ht.trucking_pricing_id = trucking_pricing.id
            ht.save!
          end
        end
        stats[:trucking_queries][:number_updated] += 1
      end
    
    end

    return {results: results, stats: stats}
  end

  def overwrite_city_trucking_rates(params, user = current_user, direction)
    
    mongo = get_client
    defaults = []
    stats = {
      type: 'trucking',
      trucking_hubs: {
        number_updated: 0,
        number_created: 0
      },
      trucking_queries: {
        number_updated: 0,
        number_created: 0
      },
      trucking_pricings: {
        number_updated: 0,
        number_created: 0
      }
    }
    results = {
      trucking_hubs: [],
      trucking_queries: [],
      trucking_pricings: []
    }
     new_trucking_pricings_array = []
    new_trucking_hubs_array = []
    new_trucking_queries_array = []
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
          tmp[:cbm_ratio] = 250
          tmp[:fees] = {
            base_rate: {
              kg: row_data[i],
              cbm: row_data[7],
              rate_basis: 'PER_CBM_KG',
              currency: "CNY"
            },
            vat: {
             value: 0.06,
              rate_basis: 'PERCENTAGE',
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
          results[:trucking_pricings] << tmp
          stats[:trucking_pricings][:number_updated] += 1
        end
        truckingQueries << ntp
        results[:trucking_queries] << ntp
        stats[:trucking_queries][:number_updated] += 1
        new_trucking_location = Location.from_short_name("#{new_pricing[:city][:city]} ,#{new_pricing[:city][:province]}", 'trucking_option')
      end
      new_trucking_hub_obj = {modifier: "city", tenant_id: user.tenant_id, nexus_id: nexus.id, load_type: 'lcl'}
      new_trucking_hubs_array << {
            :update_one => {
              :filter => {
                _id: "#{trucking_table_id}"
              },
              :update => {
                "$set" => new_trucking_hub_obj
              }, :upsert => true
            }
          }
          results[:trucking_hubs] << new_trucking_hub_obj
      stats[:trucking_hubs][:number_updated] += 1
      # update_item_fn(mongo, 'truckingHubs', {_id: trucking_table_id}, {modifier: "city", tenant_id: user.tenant_id, nexus_id: nexus.id, load_type: 'lcl'})
      truckingQueries.each do |k|
        # update_item_fn(mongo,  'truckingQueries', {_id: k[:_id]}, k)
         new_trucking_queries_array << {
            :update_one => {
              :filter => {
                _id: "#{k[:_id]}"
              },
              :update => {
                "$set" => k
              }, :upsert => true
            }
          }
      end
      truckingPricings.each do |k|
        # update_item_fn(mongo,  'truckingPricings', {_id: k[:_id]}, k)
        new_trucking_pricings_array << {
            :update_one => {
              :filter => {
                _id: "#{k[:_id]}"
              },
              :update => {
                "$set" => k
              }, :upsert => true
            }
          }
      end
    end

    mongo["truckingHubs"].bulk_write(new_trucking_hubs_array)
    mongo["truckingPricings"].bulk_write(new_trucking_pricings_array)
    mongo["truckingQueries"].bulk_write(new_trucking_queries_array)
    return {stats: stats, results: results}
  end
  def overwrite_city_trucking_rates_by_hub(params, user = current_user, hub_id, courier_name, direction)
    courier = Courier.find_or_create_by(name: courier_name)
    p direction
    mongo = get_client
    defaults = []
    stats = {
      type: 'trucking',
      trucking_hubs: {
        number_updated: 0,
        number_created: 0
      },
      trucking_queries: {
        number_updated: 0,
        number_created: 0
      },
      trucking_pricings: {
        number_updated: 0,
        number_created: 0
      }
    }
    results = {
      trucking_hubs: [],
      trucking_queries: [],
      trucking_pricings: []
    }
    
   load_type = 'cargo_item'
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      hub = Hub.find(hub_id)
      nexus = hub.nexus
      hub_truckings = []
      trucking_destinations = []
      hubs = nexus.hubs
      
      weight_cat_row = first_sheet.row(2)
      num_rows = first_sheet.last_row
      [3,4,5,6].each do |i|
        min_max_arr = weight_cat_row[i].split(" - ")
        defaults.push({min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil})
      end
      (3..num_rows).each do |line|
        row_data = first_sheet.row(line)
        new_pricing = {}
        td = TruckingDestination.find_or_create_by!(city_name: Location.get_trucking_city("#{row_data[1]}, #{row_data[0]}"), country_code: 'CN')
        hub_trucking = HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id, courier_id: courier.id)
        
        
        new_pricing[direction] = {"table" => []}
        ntp = new_pricing
        ntp[:truck_type] = 'default'
        [3,4,5,6].each do |i|
          tmp = defaults[i - 3].clone
          tmp[:delivery_eta_in_days] = row_data[10]
          ntp[:modifier] = 'kg'
          tmp[:type] = "default"
          tmp[:cbm_ratio] = 250
          tmp[:fees] = {
            base_rate: {
              kg: row_data[i],
              cbm: row_data[7],
              rate_basis: 'PER_CBM_KG',
              currency: "CNY"
            },
            vat: {
             value: 0.06,
              rate_basis: 'PERCENTAGE',
              currency: "CNY"
            }
          }
          if  direction === 'export'
            tmp[:fees][:PUF] = {value: row_data[8], currency: new_pricing[:currency], rate_basis: 'PER_SHIPMENT' }
          else
            tmp[:fees][:DLF] = {value: row_data[9], currency: new_pricing[:currency], rate_basis: 'PER_SHIPMENT' }
          end
          ntp[:load_type] = load_type
          ntp[direction]["table"] << tmp
          stats[:trucking_pricings][:number_updated] += 1
        end
        if hub_trucking.trucking_pricing_id
          trucking_pricing = TruckingPricing.find(hub_trucking.trucking_pricing_id)
          trucking_pricing.update_attributes(ntp)
        else
          trucking_pricing = courier.trucking_pricings.create!(ntp)
          hub_trucking.trucking_pricing_id = trucking_pricing.id
          hub_trucking.save!
        end
        
        # results[:trucking_queries] << ntp
        stats[:trucking_queries][:number_updated] += 1
        # new_trucking_location = Location.from_short_name("#{new_pricing[:city][:city]} ,#{new_pricing[:city][:province]}", 'trucking_option')
      end     
    end
    return {stats: stats, results: results }
  end
  def overwrite_distance_trucking_rates_by_hub(params, user = current_user, hub_id, courier_name, direction, country_code)

     courier = Courier.find_or_create_by(name: courier_name)
    p direction
    mongo = get_client
    defaults = []
    stats = {
      type: 'trucking',
      trucking_hubs: {
        number_updated: 0,
        number_created: 0
      },
      trucking_queries: {
        number_updated: 0,
        number_created: 0
      },
      trucking_pricings: {
        number_updated: 0,
        number_created: 0
      }
    }
    results = {
      trucking_hubs: [],
      trucking_queries: [],
      trucking_pricings: []
    }
    
    load_type = 'container'
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      hub = Hub.find(hub_id)
      nexus = hub.nexus
      hubs = nexus.hubs
      rows = first_sheet.parse(
        currency: 'CURRENCY',
        truck_type: 'TRUCK_TYPE',
        fee: 'FEE',
        rate: 'RATE',
        rate_basis: 'RATE_BASIS',
        range: 'RANGE',
        rate_min: 'RATE_MIN',
        rate_base_value: 'RATE_BASE_VALUE',
        x_base: 'X_BASE',
        )
      new_pricings_data = {}
      aux_data = {}
      hub_truckings = {}
      trucking_destinations = {}
      trucking_pricings = {}
      rows.each do |row|
        range_values = row[:range].split('-').map{|r| r.to_i}
        range_key = "#{row[:range]}_#{row[:truck_type]}"
        p range_key
        if !hub_truckings[range_key]
          hub_truckings[range_key] = []
        end
        if !trucking_destinations[range_key]
          trucking_destinations[range_key] = []
        end
        if !new_pricings_data[range_key]
          new_pricings_data[range_key] = { fees: {}}


          td = TruckingDestination.find_or_create_by!(distance: range_values[0], country_code: country_code)
          trucking_destinations[range_key] << td
          hub_trucking = HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id, courier_id: courier.id)
          hub_truckings[range_key] << hub_trucking
          if !aux_data[range_key]
            aux_data[range_key] = {}
          end
          if  hub_truckings[range_key][0].trucking_pricing_id && hub_truckings[range_key][0].trucking_pricing.load_type == row[:truck_type]
            p hub_truckings[range_key][0].trucking_pricing_id
            trucking_pricings[range_key] = hub_truckings[range_key][0].trucking_pricing
            trucking_pricings[range_key][direction]["table"] = []
            ((range_values[0] + 1)...range_values[1]).each do |dist|
              td = TruckingDestination.find_or_create_by!(distance: dist, country_code: country_code)
              trucking_destinations[range_key] << td
              hub_trucking = HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id, courier_id: courier.id, trucking_pricing_id: trucking_pricings[range_key])
              hub_truckings[range_key] << hub_trucking
            end
          else
            trucking_pricings[range_key] = courier.trucking_pricings.create!(export: { table: []}, import: { table: []}, load_type: load_type, truck_type: row[:truck_type], modifier: 'unit')
            trucking_destinations[range_key] = []
            hub_truckings[range_key] = []
            (range_values[0]...range_values[1]).each do |dist|
              td = TruckingDestination.find_or_create_by!(distance: dist, country_code: country_code)
              trucking_destinations[range_key] << td
              hub_trucking = HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id, courier_id: courier.id, trucking_pricing_id: trucking_pricings[range_key])
              hub_truckings[range_key] << hub_trucking
            end
          end
        end
          ntp = {
            fees: {}
          }
          case row[:rate_basis]
          when 'PER_CONTAINER'
            new_pricings_data[range_key][:fees][row[:fee]] = {
              rate_basis: 'PER_CONTAINER',
              rate: row[:rate],
              currency: row[:currency]
            }
          when 'PERCENTAGE'
            new_pricings_data[range_key][:fees][row[:fee]] = {
              rate_basis: 'PERCENTAGE',
              value: row[:rate],
              currency: row[:currency]
            }
          when 'PER_X_KM'
            new_pricings_data[range_key][:fees][row[:fee]] = {
              rate_basis: 'PER_X_KM',
              rate: row[:rate],
              rate_base_value: row[:rate_base_value],
              x_base: row[:x_base],
              currency: row[:currency]
            }
          end
          stats[:trucking_pricings][:number_updated] += 1
          
      end
      new_pricings_data.each do |range_key, fees|
        trucking_pricings[range_key][direction]["table"] << fees
      end
      hub_truckings.each do |r_key, hts|
        hts.each do |ht|
          if !ht.trucking_pricing_id
            ht.trucking_pricing_id = trucking_pricings[r_key].id
          end
          ht.save!
        end
      end
      trucking_pricings.each do |r_key, tp|
        tp.save!
      end
      stats[:trucking_queries][:number_updated] += 1
    end
    return {stats: stats, results: results}
  end
  def overwrite_local_charges(params, user = current_user)
    mongo = get_client
    stats = {
      type: 'local_charges',
      charges: {
        number_updated: 0,
        number_created: 0
      },
      customs: {
        number_updated: 0,
        number_created: 0
      }
    }
    results = {
      charges: [],
      customs: []
    }
    local_charges = []
    customs_fees = []
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      hub = Hub.find_by(name: sheet_name, tenant_id: user.tenant_id)
      hub_fees = {}
      customs = {}
      if hub
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
          minimum: 'MINIMUM',
          wm: 'WM'
        )
        
        ['lcl', 'fcl_20', 'fcl_40', 'fcl_40hq'].each do |lt|
          hub_fees[lt] = {
            "import" => {},
            "export" => {},
            "mode_of_transport" => rows[0][:mot].downcase,
            "nexus_id" => hub.nexus.id,
            "tenant_id" => hub.tenant_id,
            "hub_id" => hub.id,
            "load_type" => lt
          }
          customs[lt] = {
            "import" => {}, 
            "export" => {},
            "nexus_id" => hub.nexus.id,
            "tenant_id" => hub.tenant_id,
            "hub_id" => hub.id,
            "mode_of_transport" => rows[0][:mot].downcase,
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
            when 'PER_KG'
              charge = {currency: row[:currency], value: row[:cbm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
            when 'PER_WM'
              charge = {currency: row[:currency], value: row[:wm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
            when 'PER_ITEM'
              charge = {currency: row[:currency], value: row[:item], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
            when 'PER_CBM_TON'
              charge = {currency: row[:currency], cbm: row[:cbm], ton: row[:ton], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
            when 'PER_SHIPMENT_CONTAINER'
              charge = {currency: row[:currency], shipment: row[:shipment], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
            when 'PER_BILL_CONTAINER'
              charge = {currency: row[:currency], bill: row[:bill], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
            when 'PER_CBM_KG'
              charge = {currency: row[:currency], cbm: row[:cbm], kg: row[:kg], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
            end
            if row[:fee_code] != 'CUST'
              hub_fees = local_charge_load_setter(hub_fees, charge, row[:load_type].downcase, row[:direction].downcase, sheet_name)
            else
              customs= local_charge_load_setter(customs, charge, row[:load_type].downcase, row[:direction].downcase, sheet_name)
            end
        end
      end
      
      hub_fees.each do |k,v|
        lc_id = "#{hub.id}_#{hub.tenant_id}_#{k}"

        local_charges.push(
          {
            :replace_one => 
            {
              :filter => {:_id => lc_id},
              :replacement =>  v,
              :upsert => true
            }
          }
        )
        results[:charges] << v
        stats[:charges][:number_updated] += 1
        # update_item('localCharges', {"_id" => lc_id}, v)
      end
      customs.each do |k,v|
        lc_id = "#{hub.id}_#{hub.tenant_id}_#{k}"
         customs_fees.push(
           {
            :replace_one => 
            {
              :filter => {:_id => lc_id},
              :replacement =>  v,
              :upsert => true
            }
          }
        )
        results[:customs] << v
        stats[:customs][:number_updated] += 1
        # update_item('customsFees', {"_id" => lc_id}, v)
      end
    end
    mongo["localCharges"].bulk_write(local_charges)
    mongo["customsFees"].bulk_write(customs_fees)
    return {stats: stats, results: results}
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
    stats = {
      type: 'schedules',
      layovers: {
        number_updated: 0,
        number_created: 0
      },
      trips: {
        number_updated: 0,
        number_created: 0
      }
    }
    results = {

      layovers: [],
      trips: []
    }
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    schedules = first_sheet.parse(
      vessel: 'VESSEL', 
      call_sign: 'VOYAGE_CODE', 
      from: 'FROM', 
      to: 'TO', 
      eta: 'ETA', 
      etd: 'ETD',
      closing_date: 'CLOSING_DATE',
      service_level: 'SERVICE_LEVEL'
    )
    schedules.each do |row|
      row[:mode_of_transport] = "ocean"

      tenant = Tenant.find(current_user.tenant_id)
     service_level = row[:service_level] ? row[:service_level] : 'default'
      tenant_vehicle = TenantVehicle.find_by(
          tenant_id: user.tenant_id, 
          mode_of_transport: row[:mode_of_transport],
          name: row[:service_level]
        )
        if !tenant_vehicle
          tenant_vehicle =  Vehicle.create_from_name(service_level, row[:mode_of_transport], user.tenant_id)
        end
      startDate = row[:etd]
      endDate =  row[:eta]
      p row[:from]
      p row[:to]
      if locations[row[:from]] && locations[row[:to]]
        itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: row[:mode_of_transport], name: "#{locations[row[:from]].name} - #{locations[row[:to]].name}")
      else
        locations[row[:from]] = Location.find_by(name: "#{row[:from]}", location_type: 'nexus')
        locations[row[:to]] = Location.find_by(name: "#{row[:to]}", location_type: 'nexus')
        if locations[row[:from]] && locations[row[:to]]
          itinerary = tenant.itineraries.find_or_create_by!(mode_of_transport: row[:mode_of_transport], name: "#{locations[row[:from]].name} - #{locations[row[:to]].name}")
        else
          next
        end
      end
      origin_hub_ids = locations[row[:from]].hubs_by_type(row[:mode_of_transport], user.tenant_id).ids
      destination_hub_ids = locations[row[:to]].hubs_by_type(row[:mode_of_transport], user.tenant_id).ids
      hub_ids = origin_hub_ids + destination_hub_ids

      stops_in_order = hub_ids.map.with_index { |h, i| itinerary.stops.find_or_create_by!(hub_id: h, index: i)  }
      stops = itinerary.stops.order(:index)
      
      if itinerary
        generator_results = itinerary.generate_schedules_from_sheet(stops, startDate, endDate, tenant_vehicle.vehicle_id, row[:closing_date])
        results[:trips] = generator_results[:trips]
        results[:layovers] = generator_results[:layovers]
        stats[:trips][:number_created] = generator_results[:trips]
        stats[:layovers][:number_created] = generator_results[:layovers]
        return {results: results, stats: stats}
      else
        raise "Route cannot be found!"
      end
    end
  end
  def overwrite_schedules_by_itinerary(params, user = current_user)
    locations = {}
    stats = {
      type: 'schedules',
      layovers: {
        number_updated: 0,
        number_created: 0
      },
      trips: {
        number_updated: 0,
        number_created: 0
      }
    }
    results = {
      layovers: [],
      trips: []
    }
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    schedules = first_sheet.parse(
      vessel: 'VESSEL', 
      call_sign: 'VOYAGE_CODE', 
      from: 'FROM', 
      to: 'TO', 
      eta: 'ETA', 
      etd: 'ETD')
    schedules.each do |row|
      itinerary = params["itinerary"]

      tenant = Tenant.find(current_user.tenant_id)
     
      tenant_vehicle = TenantVehicle.find_by(
          tenant_id: user.tenant_id, 
          mode_of_transport: itinerary.mode_of_transport
        )
      startDate = row[:etd]
      endDate =  row[:eta]
      
      stops = itinerary.stops.order(:index)
      
      if itinerary
        generator_results = itinerary.generate_schedules_from_sheet(stops, startDate, endDate, tenant_vehicle.vehicle_id)
        results[:trips] = generator_results[:trips]
        results[:layovers] = generator_results[:layovers]
        stats[:trips][:number_created] = generator_results[:trips]
        stats[:layovers][:number_created] = generator_results[:layovers]
        return {results: results, stats: stats}
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
    stats = {
      type: 'hubs',
      hubs: {
        number_updated: 0,
        number_created: 0
      },
      nexuses: {
        number_updated: 0,
        number_created: 0
      }
    }
    results = {

      hubs: [],
      nexuses: []
    }
    hub_rows = first_sheet.parse( hub_status: 'STATUS', hub_type: 'TYPE', hub_name: 'NAME', hub_code: 'CODE', trucking_type: 'TRUCKING_METHOD', hub_operator: 'OPERATOR', latitude: 'LATITUDE', longitude: 'LONGITUDE', country: 'COUNTRY', geocoded_address: 'FULL_ADDRESS', photo: 'PHOTO')

    hub_type_name = {
      "ocean" => "Port",
      "air" => "Airport",
      "rail" => "Railway Station"
    }

    hub_rows.map do |hub_row|
      hub_row[:hub_type] = hub_row[:hub_type].downcase
      nexus = Location.find_by(
        name:          hub_row[:hub_name], 
        location_type: "nexus", 
        country:       hub_row[:country]
      )
      if !nexus
        nexus = Location.create!(
          name:          hub_row[:hub_name], 
          location_type: "nexus",
          latitude:      hub_row[:latitude], 
          longitude:     hub_row[:longitude], 
          photo:         hub_row[:photo], 
          country:       hub_row[:country],
          city:          hub_row[:hub_name],
          geocoded_address: hub_row[:geocoded_address]
        )
      end
      
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
      
      hub = nexus.hubs.find_by(
        nexus_id:      nexus.id, 
        location_id:   location.id, 
        tenant_id:     user.tenant_id, 
        hub_type:      hub_row[:hub_type],
        name:          "#{nexus.name} #{hub_type_name[hub_row[:hub_type]]}", 
        photo:         hub_row[:photo]
      )
      if hub
         hub.update_attributes(
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
        results[:hubs] << hub
        stats[:hubs][:number_updated] += 1
      else
         hub = nexus.hubs.create!(
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
        results[:hubs] << hub
        stats[:hubs][:number_created] += 1
      end
      results[:nexuses] << nexus
      stats[:nexuses][:number_updated] += 1
      
      hub.generate_hub_code!(user.tenant_id) unless hub.hub_code
      hub
    end
    return {stats: stats, results: results}
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

  def overwrite_mongo_lcl_pricings(params, dedicated, user = current_user, generate = false)
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
      lcl_heavy_weight_watershed_cbm: 'LCL_HEAVY_WEIGHT_WATERSHED_CBM'
      
    )
    stats = {
      type: 'pricings',
      pricings: {
        number_updated: 0,
        number_created: 0
      },
      itineraryPricings: {
        number_updated: 0,
        number_created: 0
      },
      itineraries: {
        number_updated: 0,
        number_created: 0
      },
      stops: {
        number_updated: 0,
        number_created: 0
      },
      layovers: {
        number_updated: 0,
        number_created: 0
      },
      trips: {
        number_updated: 0,
        number_created: 0
      },
      userPricings: {
        number_updated: 0,
        number_created: 0
      },
      userAffected: []
    }
    results = {
      pricings: [],
      itineraryPricings: [],
      userPricings: [],
      itineraries: [],
      stops: [],
      layovers: [],
      trips: []
    }
    new_pricings = []
    new_itinerary_pricings = {}
    pricings_array = []
    user_pricings_array = []
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
      itinerary = tenant.itineraries.find_by(mode_of_transport: row[:mot], name: "#{origin.name} - #{destination.name}")
      if !itinerary
        itinerary = tenant.itineraries.create!(mode_of_transport: row[:mot], name: "#{origin.name} - #{destination.name}")
        stats[:itineraries][:number_created] += 1
      else
        stats[:itineraries][:number_updated] += 1
      end
      results[:itineraries] << itinerary
      
      stops_in_order = hub_ids.map.with_index do |h, i| 
        temp_stop = itinerary.stops.find_by(hub_id: h, index: i)
        if temp_stop
          stats[:stops][:number_updated] += 1
          results[:stops] << temp_stop
          temp_stop
        else
          temp_stop = itinerary.stops.create!(hub_id: h, index: i)
          stats[:stops][:number_created] += 1
          results[:stops] << temp_stop
          temp_stop
        end 
      end
      
      cargo_classes = [
        'lcl'
      ]
      steps_in_order = []
      stops_in_order.length.times do 
        steps_in_order << 30
      end
      row[:effective_date] = DateTime.now
      row[:expiration_date] = row[:effective_date] + 40.days
      if generate
        generator_results = itinerary.generate_weekly_schedules(
          stops_in_order,
          steps_in_order,
          row[:effective_date], 
          row[:expiration_date], 
          [1, 5],
          vehicle.id
        )
        results[:layovers] = generator_results[:layovers]
        results[:trips] = generator_results[:trips]
        stats[:layovers][:number_created] = generator_results[:layovers].length
        stats[:trips][:number_created] = generator_results[:trips].length
      end

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
          rate_basis: 'PER_CBM',
          watershed: row[:lcl_heavy_weight_watershed_cbm]
        }
      }

      price_obj = {"lcl" =>lcl_obj.to_h}
      
      if dedicated
        stats[:userAffected] << user
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
            # _id:       priceKey,
            tenant_id: user.tenant_id,
            load_type: cargo_class
          }
          results[:pricings] << pricing
          stats[:pricings][:number_created] += 1
          pricings_array.push({
            :update_one => {
              :filter => {
                _id: "#{priceKey}"
              },
              :update => {
                "$set" => pricing
              }, :upsert => true
            }
          })
          # update_item_fn(mongo, 'pricings', {_id: "#{priceKey}"}, pricing)
          
          user_pricing = { pathKey => priceKey}
          user_pricings_array << {
            :update_one => {
              :filter => {
                _id: "#{user.id}"
              },
              :update => {
                "$set" => user_pricing
              }, :upsert => true
            }
          }
          results[:userPricings] << user_pricing
          stats[:userPricings][:number_created] += 1
          # update_item_fn(mongo, 'userPricings', {_id: "#{user.id}"}, user_pricing)
          
          new_itinerary_pricings[pathKey] ||= {}
          new_itinerary_pricings[pathKey]["#{user.id}"] = priceKey
          new_itinerary_pricings[pathKey]["tenant_id"]             = user.tenant_id
          new_itinerary_pricings[pathKey]["itinerary_id"]          = itinerary.id
          new_itinerary_pricings[pathKey]["transport_category_id"] = transport_category.id
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
            # _id:          priceKey,
            itinerary_id: itinerary.id,
            tenant_id:    user.tenant_id
          }
          results[:pricings] << pricing
          stats[:pricings][:number_created] += 1
          pricings_array.push({
            :update_one => {
              :filter => {
                _id: "#{priceKey}"
              },
              :update => {
                "$set" => pricing
              }, :upsert => true
            }
          })

          # update_item_fn(mongo, 'pricings', {_id: "#{priceKey}"}, pricing)
          

          new_itinerary_pricings[pathKey] ||= {}
          new_itinerary_pricings[pathKey]["open"]                  = priceKey
          new_itinerary_pricings[pathKey]["tenant_id"]             = user.tenant_id
          new_itinerary_pricings[pathKey]["itinerary_id"]          = itinerary.id
          new_itinerary_pricings[pathKey]["transport_category_id"] = transport_category.id
        end
      end
    end
    itinerary_pricings_array = []
    new_itinerary_pricings.each do |key, value|
      results[:itineraryPricings] << value
      stats[:itineraryPricings][:number_created] += 1
      itinerary_pricings_array << {
            :update_one => {
              :filter => {
                _id: "#{key}"
              },
              :update => {
                "$set" => value
              }, :upsert => true
            }
          }
      # update_itinerary_pricing(key, value)
    end
    mongo["itineraryPricings"].bulk_write(itinerary_pricings_array)
    mongo["pricings"].bulk_write(pricings_array)
    mongo["userPricings"].bulk_write(user_pricings_array)
    return {results: results, stats: stats}
  end
  def overwrite_freight_rates(params, user = current_user, generate = false)
    mongo = get_client
     stats = {
      type: 'pricings',
      pricings: {
        number_updated: 0,
        number_created: 0
      },
      itineraryPricings: {
        number_updated: 0,
        number_created: 0
      },
      itineraries: {
        number_updated: 0,
        number_created: 0
      },
      stops: {
        number_updated: 0,
        number_created: 0
      },
      layovers: {
        number_updated: 0,
        number_created: 0
      },
      trips: {
        number_updated: 0,
        number_created: 0
      },
      userPricings: {
        number_updated: 0,
        number_created: 0
      },
      userAffected: []
    }
    results = {
      pricings: [],
      itineraryPricings: [],
      userPricings: [],
      itineraries: [],
      stops: [],
      layovers: [],
      trips: []
    }
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    pricing_rows = first_sheet.parse(
      customer_id: 'CUSTOMER_ID',
      mot: 'MOT',
      cargo_type: 'CARGO_TYPE',
      effective_date: 'EFFECTIVE_DATE',
      expiration_date: 'EXPIRATION_DATE',
      origin: 'ORIGIN',
      destination: 'DESTINATION',
      vehicle: 'VEHICLE',
      fee: 'FEE',
      currency: 'CURRENCY',
      rate_basis: 'RATE_BASIS',
      rate_min: 'RATE_MIN',
      rate: 'RATE',
      hw_threshold: 'HW_THRESHOLD',
      hw_rate_basis: 'HW_RATE_BASIS',
      min_range: 'MIN_RANGE',
      max_range: 'MAX_RANGE',
      transit_time: 'TRANSIT TIME',
      carrier: 'CARRIER',
      nested: 'NESTED'
    )
    tenant = user.tenant
    new_hub_route_pricings = {}
    aux_data = {}
    new_pricings = {}
    nested_pricings = {}
    new_itinerary_pricings = {}
    pricings_to_write = []
    user_pricings_to_write = []
    itinerary_pricings_to_write = []
    customer = false
    pricing_rows.each do |row|
      pricing_key = "#{row[:origin].gsub(/\s+/, "").gsub(/,+/, "")}_#{row[:destination].gsub(/\s+/, "").gsub(/,+/, "")}"
      if !new_pricings[pricing_key]
        new_pricings[pricing_key] = {
          
        }
      end
      if row[:customer_id]
        aux_data[pricing_key][:customer] = row[:customer_id]
      end
      effective_date = DateTime.parse(row[:effective_date].to_s)
      expiration_date = DateTime.parse(row[:expiration_date].to_s)
      mot = row[:mot]
      cargo_type = row[:cargo_type]
      if !new_pricings[pricing_key][cargo_type]
        new_pricings[pricing_key][cargo_type] = {
          data: {},
          exceptions: [],
          effective_date: effective_date, 
          expiration_date: expiration_date, 
          updated_at: DateTime.now
        }
      end
      if !aux_data[pricing_key]
        aux_data[pricing_key] = {}
      end
      if !aux_data[pricing_key][:vehicle]
        vehicle = Vehicle.find_by_name(row[:vehicle])
        if  vehicle
          aux_data[pricing_key][:vehicle] = vehicle
        else
          aux_data[pricing_key][:vehicle] = Vehicle.find_by_name("#{row[:mot]}_default")
        end
      end
      if !aux_data[pricing_key][:transit_time]
        aux_data[pricing_key][:transit_time] = row[:transit_time]
      end
      if !aux_data[pricing_key][:origin]
        aux_data[pricing_key][:origin] = Location.find_by(name: row[:origin], location_type: 'nexus')
      end
      if !aux_data[pricing_key][:destination]
        aux_data[pricing_key][:destination] = Location.find_by(name: row[:destination], location_type: 'nexus')
      end
      
      if !aux_data[pricing_key][:origin_hub_ids]
        aux_data[pricing_key][:origin_hub_ids] = aux_data[pricing_key][:origin].hubs_by_type(row[:mot], user.tenant_id).ids
      end
      if !aux_data[pricing_key][:destination_hub_ids]
        aux_data[pricing_key][:destination_hub_ids] = aux_data[pricing_key][:destination].hubs_by_type(row[:mot], user.tenant_id).ids
      end

      aux_data[pricing_key][:hub_ids] = aux_data[pricing_key][:origin_hub_ids] + aux_data[pricing_key][:destination_hub_ids]
      itinerary_name = "#{aux_data[pricing_key][:origin].name} - #{aux_data[pricing_key][:destination].name}"
      if !aux_data[pricing_key][:itinerary]
        itinerary = tenant.itineraries.find_by(mode_of_transport: row[:mot], name: itinerary_name)
        if !itinerary
          itinerary = tenant.itineraries.create!(mode_of_transport: row[:mot], name: itinerary_name)
          stats[:itineraries][:number_created] += 1
        else
          stats[:itineraries][:number_updated] += 1
        end
        aux_data[pricing_key][:itinerary] = itinerary
      end
      aux_data[pricing_key][:stops_in_order] = aux_data[pricing_key][:hub_ids].map.with_index do |h, i| 
        temp_stop = aux_data[pricing_key][:itinerary].stops.find_by(hub_id: h, index: i)
        if temp_stop
          stats[:stops][:number_updated] += 1
          results[:stops] << temp_stop
          temp_stop
        else
          temp_stop = aux_data[pricing_key][:itinerary].stops.create!(hub_id: h, index: i)
          stats[:stops][:number_created] += 1
          results[:stops] << temp_stop
          temp_stop
        end 
      end
     
      steps_in_order = []
      aux_data[pricing_key][:stops_in_order].length.times do 
        steps_in_order << aux_data[pricing_key][:transit_time].to_i
      end
      start_date = DateTime.now
      end_date = start_date + 40.days
      if generate
        generator_results = aux_data[pricing_key][:itinerary].generate_weekly_schedules(
          aux_data[pricing_key][:stops_in_order],
          steps_in_order,
          start_date, 
          end_date, 
          [1, 5],
          aux_data[pricing_key][:vehicle].id
        )
        results[:layovers] = generator_results[:layovers]
        results[:trips] = generator_results[:trips]
        stats[:layovers][:number_created] = generator_results[:layovers].length
        stats[:trips][:number_created] = generator_results[:trips].length
      end
      if row[:nested] && row[:nested] != ''
        nested_key = "#{effective_date.to_i.to_s}_#{aux_data[pricing_key][:itinerary].id}"
        
          if !nested_pricings[pricing_key]
            nested_pricings[pricing_key] = { "#{cargo_type}" => {}}
          end
          if !nested_pricings[pricing_key][cargo_type][nested_key]
            nested_pricings[pricing_key][cargo_type][nested_key] = {
              data: {}, 
              effective_date: effective_date,
              expiration_date: expiration_date
            }
          end
          if !nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]]
            nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]] = {
              rate: row[:rate],
              rate_basis: row[:rate_basis],
              currency: row[:currency]
            }
          end
          if row[:hw_threshold]
            nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:hw_threshold] = row[:hw_threshold]
          end
          if row[:hw_rate_basis]
            nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:hw_rate_basis] = row[:hw_rate_basis]
          end
          if row[:min_range]
            nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]].delete("rate")
            if !nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:range]
              nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:range] = []
            end
            nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:range] << {
              min: row[:min_range],
              max: row[:max_range],
              rate: row[:rate]
            }
          end
          if row[:rate_min]
            nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:min] = row[:rate_min]
          end
      else
          if !new_pricings[pricing_key][cargo_type][:data][row[:fee]]
            new_pricings[pricing_key][cargo_type][:data][row[:fee]] = {
              rate: row[:rate],
              rate_basis: row[:rate_basis],
              currency: row[:currency]
            }
          end
          if row[:hw_threshold]
            new_pricings[pricing_key][cargo_type][:data][row[:fee]][:hw_threshold] = row[:hw_threshold]
          end
          if row[:hw_rate_basis]
            new_pricings[pricing_key][cargo_type][:data][row[:fee]][:hw_rate_basis] = row[:hw_rate_basis]
          end
          if row[:min_range]
            new_pricings[pricing_key][cargo_type][:data][row[:fee]].delete("rate")
            if !new_pricings[pricing_key][cargo_type][:data][row[:fee]][:range]
              new_pricings[pricing_key][cargo_type][:data][row[:fee]][:range] = []
            end
            new_pricings[pricing_key][cargo_type][:data][row[:fee]][:range] << {
              min: row[:min_range],
              max: row[:max_range],
              rate: row[:rate]
            }
          end
          if row[:rate_min]
            new_pricings[pricing_key][cargo_type][:data][row[:fee]][:min] = row[:rate_min]
          end
      end
    end
    nested_pricings.each do |p_key, cargo_values|
      cargo_values.each do |c_key, nested_values|
        nested_values.each do |n_key, value|
        new_pricings[p_key][c_key][:exceptions] << value
        end
      end
    end
      new_pricings.each do |itKey, cargo_pricings|
        cargo_pricings.each do |cargo_key, pricing|
         
          transport_category = aux_data[itKey][:vehicle].transport_categories.find_by(
            name: "any", 
            cargo_class: cargo_key
          )
          tmp_pricing = pricing
          tmp_pricing[:itinerary_id] = aux_data[itKey][:itinerary].id
          tmp_pricing[:tenant_id] = tenant.id
          tmp_pricing[:load_type] = cargo_key
          uuid = SecureRandom.uuid
          pathKey = "#{aux_data[itKey][:stops_in_order][0].id}_#{aux_data[itKey][:stops_in_order].last.id}_#{transport_category.id}"
          priceKey = "#{aux_data[itKey][:stops_in_order][0].id}_#{aux_data[itKey][:stops_in_order].last.id}_#{transport_category.id}_#{user.tenant_id}_#{cargo_key}"
          if aux_data[itKey][:customer]
            priceKey += "_#{aux_data[itKey][:customer]}"
            user_pricing = { pathKey => priceKey }
            pricings_to_write << {
              :update_one => {
                :filter => {
                  _id: priceKey
                },
                :update => {
                  "$set" => tmp_pricing
                }, :upsert => true
              }
            }
            user_pricings_to_write << {
              :update_one => {
                :filter => {
                  _id: "#{aux_data[itKey][:customer]}"
                },
                :update => {
                  "$set" => user_pricing
                }, :upsert => true
              }
            }
            results[:userPricings] << user_pricing
            stats[:userPricings][:number_created] += 1
            results[:pricings] << tmp_pricing
            stats[:pricings][:number_created] += 1
            new_itinerary_pricings[pathKey] ||= {}
            new_itinerary_pricings[pathKey]["#{aux_data[itKey][:customer]}"] = priceKey
            new_itinerary_pricings[pathKey]["itinerary_id"]          = aux_data[itKey][:itinerary].id
            new_itinerary_pricings[pathKey]["tenant_id"]             = user.tenant_id
            new_itinerary_pricings[pathKey]["transport_category_id"] = transport_category.id
          else
            pricings_to_write << {
              :update_one => {
                :filter => {
                  _id: priceKey
                },
                :update => {
                  "$set" => tmp_pricing
                }, :upsert => true
              }
            }
            results[:pricings] << tmp_pricing
            stats[:pricings][:number_created] += 1
            new_itinerary_pricings[pathKey] ||= {}
            new_itinerary_pricings[pathKey]["open"]                  = priceKey
            new_itinerary_pricings[pathKey]["itinerary_id"]          = aux_data[itKey][:itinerary].id
            new_itinerary_pricings[pathKey]["tenant_id"]             = user.tenant_id
            new_itinerary_pricings[pathKey]["transport_category_id"] = transport_category.id
          end
        end
      end
      new_itinerary_pricings.each do |key, value|
        results[:itineraryPricings] << value
        stats[:itineraryPricings][:number_created] += 1
        itinerary_pricings_to_write << {
              :update_one => {
                :filter => {
                  _id: key
                },
                :update => {
                  "$set" => value
                }, :upsert => true
              }
            }
      end
      mongo["itineraryPricings"].bulk_write(itinerary_pricings_to_write)
      mongo["pricings"].bulk_write(pricings_to_write)
      mongo["userPricings"].bulk_write(user_pricings_to_write)
      sleep(5)
      tenant.update_route_details()
      return {results: results, stats: stats}
  end
  def overwrite_mongo_maersk_fcl_pricings(params, dedicated, user = current_user, generate = false)
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
    stats = {
      type: 'pricings',
      pricings: {
        number_updated: 0,
        number_created: 0
      },
      itineraryPricings: {
        number_updated: 0,
        number_created: 0
      },
      itineraries: {
        number_updated: 0,
        number_created: 0
      },
      stops: {
        number_updated: 0,
        number_created: 0
      },
      layovers: {
        number_updated: 0,
        number_created: 0
      },
      trips: {
        number_updated: 0,
        number_created: 0
      },
      userPricings: {
        number_updated: 0,
        number_created: 0
      },
      userAffected: []
    }
    results = {
      pricings: [],
      itineraryPricings: [],
      userPricings: [],
      itineraries: [],
      stops: [],
      layovers: [],
      trips: []
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
        itinerary = tenant.itineraries.find_by(mode_of_transport: row[:mot], name: "#{origin.name} - #{destination.name}")
        if !itinerary
          itinerary = tenant.itineraries.create!(mode_of_transport: row[:mot], name: "#{origin.name} - #{destination.name}")
          stats[:itineraries][:number_created] += 1
        else
          stats[:itineraries][:number_updated] += 1
        end
        results[:itineraries] << itinerary
      
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
      new_pricings_aux_data[pricing_key][:stops_in_order] = new_pricings_aux_data[pricing_key][:hub_ids].map.with_index do |h, i| 
        temp_stop = new_pricings_aux_data[pricing_key][:itinerary].stops.find_by(hub_id: h, index: i)
        if temp_stop
          stats[:stops][:number_updated] += 1
          results[:stops] << temp_stop
          temp_stop
        else
          temp_stop = new_pricings_aux_data[pricing_key][:itinerary].stops.create!(hub_id: h, index: i)
          stats[:stops][:number_created] += 1
          results[:stops] << temp_stop
          temp_stop
        end 
      end
      
      steps_in_order = []
      new_pricings_aux_data[pricing_key][:stops_in_order].length.times do 
        steps_in_order << 30
      end
      row[:effective_date] = DateTime.now
      row[:expiration_date] = row[:effective_date] + 40.days
      if generate
      generator_results = new_pricings_aux_data[pricing_key][:itinerary].generate_weekly_schedules(
        new_pricings_aux_data[pricing_key][:stops_in_order],
        steps_in_order,
        row[:effective_date], 
        row[:expiration_date], 
        [1, 5],
        vehicle.id
      )
      results[:layovers] = generator_results[:layovers]
        results[:trips] = generator_results[:trips]
        stats[:layovers][:number_created] = generator_results[:layovers].length
        stats[:trips][:number_created] = generator_results[:trips].length
      end
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
          results[:userPricings] << user_pricing
          stats[:userPricings][:number_created] += 1
          results[:pricings] << pricing_data
          stats[:pricings][:number_created] += 1
          new_hub_route_pricings[pathKey] ||= {}
          new_hub_route_pricings[pathKey]["#{user.id}"] = priceKey
          new_hub_route_pricings[pathKey]["itinerary_id"]          = new_pricings_aux_data[pricing_key][:itinerary].id
          new_hub_route_pricings[pathKey]["tenant_id"]             = user.tenant_id
          new_hub_route_pricings[pathKey]["transport_category_id"] = transport_category.id
        else
          
          update_item_fn(mongo, 'pricings', {_id: priceKey}, pricing_data)
          results[:pricings] << pricing_data
          stats[:pricings][:number_created] += 1
          new_hub_route_pricings[pathKey] ||= {}
          new_hub_route_pricings[pathKey]["open"]                  = priceKey
          new_hub_route_pricings[pathKey]["itinerary_id"]          = new_pricings_aux_data[pricing_key][:itinerary].id
          new_hub_route_pricings[pathKey]["tenant_id"]             = user.tenant_id
          new_hub_route_pricings[pathKey]["transport_category_id"] = transport_category.id
        end
      end
    end
    new_hub_route_pricings.each do |key, value|
       results[:itineraryPricings] << value
      stats[:itineraryPricings][:number_created] += 1
      update_itinerary_pricing(key, value)
    end
    return {results: results, stats: stats}
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

  def local_charge_load_setter(all_charges, charge, load_type, direction, test)
    p charge
    p all_charges
    if load_type === 'fcl'
      ['fcl_20', 'fcl_40', 'fcl_40hq'].each do |lt|
        p test
        p all_charges[lt]
        p  all_charges[lt][direction]
        p charge 
        p test
        all_charges[lt][direction][charge[:key]] = charge
      end
    else
      all_charges[load_type][direction][charge[:key]] = charge
    end
    return all_charges
  end
end
