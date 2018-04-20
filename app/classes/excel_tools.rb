# frozen_string_literal: true
DEBUG = false

module ExcelTools
  include ImageTools
  include MongoTools
  include PricingTools

  def handle_zipcode_sections(rows, _user, direction, hub_id, courier_name, load_type, defaults, weight_min_row, meta)
    courier = Courier.find_or_create_by(name: courier_name)
    rows.each do |row_data|
      zip_code_range_array = row_data.shift.split(' - ')
      zip_code_range = (zip_code_range_array[0].to_i...zip_code_range_array[1].to_i)
      row_min_value = row_data.shift

      trucking_pricing = TruckingPricing.new(
        export: { table: [] },
        import: { table: [] },
        load_type: meta[:load_type],
        load_meterage: {
          ratio: meta[:load_meterage_ratio],
          height_limit: 130
        },
        cbm_ratio: meta[:cbm_ratio],
        courier: courier,
        modifier: meta[:modifier],
        truck_type: 'default'
      )

      trucking_pricing[direction]['table'] = row_data.map.with_index do |val, i|
        next if !val || !weight_min_row[i]

        defaults[i].clone.merge(
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
        )
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

      trucking_pricing_should_update.try(:update, direction => { 'table' => trucking_pricing[direction]['table'] })
    end
  end

  def split_zip_code_sections(params, user = current_user, hub_id, courier_name, direction)
    defaults = []
    load_type = 'cargo_item'
    no_of_jobs = 10
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      num_rows = first_sheet.last_row
      rows_per_job = ((num_rows - 4) / no_of_jobs).to_i

      rows_for_job = []
      (0...no_of_jobs - 1).each do |index|
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
      fuel_charge = meta_row[13]
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
        next unless cell
        min_max_arr = cell.split(' - ')
        defaults.push(min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil)
      end

      rows_for_job.each do |rfj|
        job_id = SecureRandom.uuid
        update_item('jobs', { _id: job_id }, completed: false, created: DateTime.now)
        worker_obj = {
          defaults: defaults,
          weight_min_row: weight_min_row,
          rows_for_job: rfj.clone,
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
            fuel_charge: fuel_charge,
            load_meterage_ratio: load_meterage_ratio,
            base: base
          }
        }

        ExcelWorker.perform_async(worker_obj)
      end
    end

    # handle_zipcode_sections(test_array[0][:rows_for_job], user, test_array[0][:direction], test_array[0][:hub_id], test_array[0][:courier_name], test_array[0][:load_type], test_array[0][:defaults], test_array[0][:weight_min_row], test_array[0][:currency])
  end

  def overwrite_zipcode_trucking_rates_by_hub(params, _user = current_user, hub_id, courier_name, direction)
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
    load_type = 'cargo_item'
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      num_rows = first_sheet.last_row
      hub = Hub.find(hub_id)
      nexus = hub.nexus
      currency_row = first_sheet.row(1)
      header_row = first_sheet.row(2)
      header_row.shift
      header_row.shift
      weight_min_row = first_sheet.row(3)
      weight_min_row.shift
      weight_min_row.shift

      header_row.each do |cell|
        next unless cell
        min_max_arr = cell.split(' - ')
        defaults.push(min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil)
      end

      (4..num_rows).each do |line|
        row_data = first_sheet.row(line)
        zip_code_range_array = row_data.shift.split(' - ')
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
          trucking_pricing = courier.trucking_pricings.create!(tenant_id: hub.tenant_id, export: { table: [] }, import: { table: [] }, load_type: load_type)
        end

        row_data.each_with_index do |val, index|
          next if !val || !weight_min_row[index]
          tmp = defaults[index].clone
          min_value = if row_min_value < weight_min_row[index]
                        weight_min_row[index]
                      else
                        row_min_value
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

          if direction == 'export'
            tmp[:fees][:congestion] = {
              value: 15,
              rate_basis: 'PER_ITEM',
              currency: currency_row[3]
            }
          end
          if direction == 'import'
            tmp[:fees][:congestion] = {
              value: 15,
              rate_basis: 'PER_ITEM',
              currency: currency_row[3]
            }
          end

          tmp[:direction] = direction
          tmp[:type] = 'default'
          trucking_pricing['load_meterage'] = {
            ratio: 1950,
            height_limit: 130
          }
          trucking_pricing[:modifier] = 'kg'
          trucking_pricing[direction]['table'].push(tmp)
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

    { results: results, stats: stats }
  end

  def overwrite_distance_trucking_rates_by_hub(params, _user = current_user, hub_id, courier_name, direction, country_code)
    courier = Courier.find_or_create_by(name: courier_name)
    p direction

    stats = {
      type: "trucking",
      trucking_hubs: {
        number_updated: 0,
        number_created: 0,
      },
      trucking_queries: {
        number_updated: 0,
        number_created: 0,
      },
      trucking_pricings: {
        number_updated: 0,
        number_created: 0,
      },
    }

    results = {
      trucking_hubs: [],
      trucking_queries: [],
      trucking_pricings: [],
    }

    load_type = "container"
    xlsx = Roo::Spreadsheet.open(params["xlsx"])

    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      hub = Hub.find(hub_id)
      nexus = hub.nexus
      rows = first_sheet.parse(
        currency: "CURRENCY",
        truck_type: "TRUCK_TYPE",
        fee: "FEE",
        rate: "RATE",
        rate_basis: "RATE_BASIS",
        range: "RANGE",
        rate_min: "RATE_MIN",
        rate_base_value: "RATE_BASE_VALUE",
        x_base: "X_BASE",
      )
      new_pricings_data = {}
      aux_data = {}
      hub_truckings = {}
      trucking_destinations = {}
      trucking_pricings = {}

      rows.each do |row|
        range_values = row[:range].split("-").map(&:to_i)
        range_key = "#{row[:range]}_#{row[:truck_type]}"
        p range_key
        hub_truckings[range_key] = [] unless hub_truckings[range_key]
        unless trucking_destinations[range_key]
          trucking_destinations[range_key] = []
        end
        unless new_pricings_data[range_key]
          new_pricings_data[range_key] = {fees: {}}
          td = TruckingDestination.find_or_create_by!(distance: range_values[0], country_code: country_code)
          trucking_destinations[range_key] << td
          hub_trucking = HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id)
          hub_truckings[range_key] << hub_trucking

          aux_data[range_key] = {} unless aux_data[range_key]

          if hub_truckings[range_key][0].trucking_pricing_id && hub_truckings[range_key][0].trucking_pricing.load_type == row[:truck_type]
            p hub_truckings[range_key][0].trucking_pricing_id
            trucking_pricings[range_key] = hub_truckings[range_key][0].trucking_pricing
            trucking_pricings[range_key][direction]["table"] = []

            ((range_values[0] + 1)...range_values[1]).each do |dist|
              td = TruckingDestination.find_or_create_by!(distance: dist, country_code: country_code)
              trucking_destinations[range_key] << td
              hub_trucking = HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id, trucking_pricing_id: trucking_pricings[range_key])
              hub_truckings[range_key] << hub_trucking
            end
          else
            trucking_pricings[range_key] = courier.trucking_pricings.create!(tenant_id: hub.tenant_id, export: {table: []}, import: {table: []}, load_type: load_type, truck_type: row[:truck_type], modifier: "unit")
            trucking_destinations[range_key] = []
            hub_truckings[range_key] = []
            (range_values[0]...range_values[1]).each do |dist|
              td = TruckingDestination.find_or_create_by!(distance: dist, country_code: country_code)
              trucking_destinations[range_key] << td
              hub_trucking = HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id, trucking_pricing_id: trucking_pricings[range_key])
              hub_truckings[range_key] << hub_trucking
            end
          end
        end
        case row[:rate_basis]
        when "PER_CONTAINER"
          new_pricings_data[range_key][:fees][row[:fee]] = {
            rate_basis: "PER_CONTAINER",
            rate: row[:rate],
            currency: row[:currency],
          }
        when "PERCENTAGE"
          new_pricings_data[range_key][:fees][row[:fee]] = {
            rate_basis: "PERCENTAGE",
            value: row[:rate],
            currency: row[:currency],
          }
        when "PER_X_KM"
          new_pricings_data[range_key][:fees][row[:fee]] = {
            rate_basis: "PER_X_KM",
            rate: row[:rate],
            rate_base_value: row[:rate_base_value],
            x_base: row[:x_base],
            currency: row[:currency],
          }
        end
        stats[:trucking_pricings][:number_updated] += 1
      end

      new_pricings_data.each do |range_key, fees|
        trucking_pricings[range_key][direction]["table"] << fees
      end

      hub_truckings.each do |r_key, hts|
        hts.each do |ht|
          unless ht.trucking_pricing_id
            ht.trucking_pricing_id = trucking_pricings[r_key].id
          end
          ht.save!
        end
      end
      trucking_pricings.each do |_r_key, tp|
        tp.save!
      end

      stats[:trucking_queries][:number_updated] += 1
    end
    {stats: stats, results: results}
  end

  def overwrite_zonal_trucking_rates_by_hub(params, _user = current_user, hub_id)
    stats = {
      type: 'trucking',
      trucking_hubs: {
        number_updated: 0,
        number_created: 0
      },
      hub_truckings: {
        number_updated: 0,
        number_created: 0
      },
      trucking_pricings: {
        number_updated: 0,
        number_created: 0,
      },
      trucking_destinations: {
        number_updated: 0,
        number_created: 0,
      },
    }

    results = {
      trucking_hubs: [],
      hub_truckings: [],
      trucking_pricings: [],
      trucking_destinations: []
    }

    defaults = {}
    load_type = 'cargo_item'
    trucking_pricing_by_zone = {}
    hub = Hub.find(hub_id)
    tenant = hub.tenant
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    sheets = xlsx.sheets
    zone_sheet = xlsx.sheet(sheets.first)

    currency = zone_sheet.row(2)[7]
    load_meterage_ratio = zone_sheet.row(3)[7]
    load_meterage_limit = zone_sheet.row(4)[7]
    cbm_ratio = zone_sheet.row(5)[7]
    modifier = zone_sheet.row(6)[7]
    rate_basis = zone_sheet.row(7)[7]
    base = zone_sheet.row(8)[7]
    load_type = zone_sheet.row(9)[7] == 'container' ? 'container' : 'cargo_item'
    identifier_type = zone_sheet.row(10)[7] == 'city' ? 'city_name' : zone_sheet.row(10)[7]
    courier = Courier.find_or_create_by(name: zone_sheet.row(9)[7])
    num_rows = zone_sheet.last_row

    # START Load Zones ------------------------
    zones = {}
    (2..num_rows).each do |line|
      row_data = zone_sheet.row(line)
      zones[row_data[0]] = [] unless zones[row_data[0]]
      if row_data[1] && !row_data[2]
        zones[row_data[0]] << { id: row_data[1], country: row_data[3] }
      elsif !row_data[1] && row_data[2]
        range = row_data[2].delete(' ').split('-')
        zones[row_data[0]] << { min: range[0].to_d, max: range[1].to_d, country: row_data[3] }
      end
    end
    # END Load Zones ------------------------

    # START Load Fees & Charges ------------------------
    fees_sheet = xlsx.sheet(sheets[2])

    rows = fees_sheet.parse(
      fee: 'FEE',
      mot: 'MOT',
      fee_code: 'FEE_CODE',
      truck_type: 'TRUCK_TYPE',
      direction: 'DIRECTION',
      currency: 'CURRENCY',
      rate_basis: 'RATE_BASIS',
      ton: 'TON',
      cbm: 'CBM',
      kg: 'KG',
      item: 'ITEM',
      shipment: 'SHIPMENT',
      bill: 'BILL',
      container: 'CONTAINER',
      minimum: 'MINIMUM',
      wm: 'WM',
      percentage: 'PERCENTAGE'
    )
    charges = {}

    rows.each do |row|
      case row[:rate_basis]
      when 'PER_SHIPMENT'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], value: row[:shipment], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when 'PER_CONTAINER'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], value: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when 'PER_BILL'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], value: row[:bill], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when 'PERCENTAGE'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], value: row[:percentage], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when 'PER_CBM'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], value: row[:cbm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when 'PER_KG'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], value: row[:cbm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when 'PER_WM'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], value: row[:wm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when 'PER_ITEM'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], value: row[:item], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when 'PER_CBM_TON'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], cbm: row[:cbm], ton: row[:ton], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when 'PER_SHIPMENT_CONTAINER'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], shipment: row[:shipment], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when 'PER_BILL_CONTAINER'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], bill: row[:bill], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when 'PER_CBM_KG'
        charges[row[:fee_code]] = { direction: row[:direction], truck_type: row[:truck_type], currency: row[:currency], cbm: row[:cbm], kg: row[:kg], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      end
    end
    # END Load Fees & Charges ------------------------

    # START Determine how many columns the modifiers span ------------------------
    rates_sheet = xlsx.sheet(sheets[1])
    rate_num_rows = rates_sheet.last_row
    modifier_position_objs = {}
    modifier_row = rates_sheet.row(1)
    modifier_row.shift
    modifier_row.shift
    modifier_row.shift
    modifier_row.uniq.each do |mod|
      modifier_position_objs[mod] = modifier_row.each_index.select { |index| modifier_row[index] == mod }
    end
    header_row = rates_sheet.row(2)
    header_row.shift
    header_row.shift
    header_row.shift

    weight_min_row = rates_sheet.row(3)
    weight_min_row.shift
    weight_min_row.shift
    weight_min_row.shift

    modifier_position_objs.each do |mod_key, mod_indexes|
      header_row.each_with_index do |cell, i|
        next if !cell || !mod_indexes.include?(i)
        defaults[mod_key] = {} unless defaults[mod_key]
        min_max_arr = cell.split(" - ")
        defaults[mod_key][i] = {"min_#{mod_key}": min_max_arr[0].to_d, "max_#{mod_key}": min_max_arr[1].to_d, min_value: nil}.symbolize_keys
      end
    end
    # END Determine how many columns the modifiers span ------------------------

    # START Rates ------------------------
    (4..rate_num_rows).each do |line|
      row_data = rates_sheet.row(line)
      row_zone_name = row_data.shift
      row_truck_type = row_data.shift
      row_truck_type = 'default' if !row_truck_type || row_truck_type == ''
      row_min_value = row_data.shift
      row_key = "#{row_zone_name}_#{row_truck_type}"

      single_ident_values_and_country = zones[row_zone_name].flat_map do |idents_and_country|
        if idents_and_country[:min] && idents_and_country[:max]
          (idents_and_country[:min].to_i..idents_and_country[:max].to_i).map do |ident|
            stats[:trucking_destinations][:number_created] += 1
            {id: ident, country: idents_and_country[:country]}
          end
        elsif identifier_type == "city_name"
          city = Location.get_trucking_city("#{idents_and_country[:id].to_s}, #{idents_and_country[:country]}")
          puts "!!!"
          puts "!!!"
          puts "!!!"
          awesome_print city
          stats[:trucking_destinations][:number_created] += 1
          stats[:hub_truckings][:number_created] += 1
          awesome_print idents_and_country[:country]
          { id: city, country: idents_and_country[:country] }
        else
          idents_and_country
        end
      end

      single_ident_values = single_ident_values_and_country.map { |h| h[:id] }
      single_country_values = single_ident_values_and_country.map { |h| h[:country] }

      %w[pre on].each do |direction|

        trucking_pricing_by_zone[row_key] = TruckingPricing.new(
          rates: {},
          fees: {},
          carriage: direction,
          load_type: load_type,
          load_meterage: {
            ratio: load_meterage_ratio,
            height_limit: 130
          },
          cbm_ratio: cbm_ratio,
          courier: courier,
          modifier: modifier,
          truck_type: row_truck_type,
          tenant_id: tenant.id
        )
          stats[:trucking_pricings][:number_created] += 1
        modifier_position_objs.each do |mod_key, mod_indexes|
          trucking_pricing_by_zone[row_key].rates[mod_key] = mod_indexes.map do |m_index|
            val = row_data[m_index]
            next unless val
            w_min = weight_min_row[m_index] || 0
            r_min = row_min_value || 0
            if defaults[mod_key]
              mod_cell = defaults[mod_key][m_index].clone.merge(
                min_value: [w_min, r_min].max,
                rate: {
                  value: val,
                  rate_basis: rate_basis,
                  currency: currency,
                  base: base,
                },
              )
            else
              mod_cell = {
                min_value: 0,
                rate: {
                  value: val,
                  rate_basis: rate_basis,
                  currency: currency,
                  base: base,
                }
              }
            end
          end
        end
        
        charges.each do |k, fee|
          next unless fee[:direction] == direction && fee[:truck_type] == row_truck_type
          fee.delete(:direction)
          fee.delete(:truck_type)
          trucking_pricing_by_zone[row_key][:fees][k] = fee
        end

        single_ident_values_and_country_with_timestamps =
          identifier_type == 'distance' ?
          single_ident_values_and_country.map do |h|
            "(#{h[:id]}, '#{h[:country]}', current_timestamp, current_timestamp)"
          end.join(", ") :
          single_ident_values_and_country.map do |h|
            "('#{h[:id]}', '#{h[:country]}', current_timestamp, current_timestamp)"
          end.join(", ")

        tp = trucking_pricing_by_zone[row_key]

        new_cols = %w(carriage cbm_ratio courier_id load_meterage load_type modifier tenant_id truck_type)
        new_cols.delete("cbm_ratio") if load_type == "container"
        #  
        
        # Find or update trucking_destinations
        td_query = <<-eos
          WITH  
            existing_identifiers AS (
              SELECT id, #{identifier_type}, country_code FROM trucking_destinations
              WHERE trucking_destinations.#{identifier_type} IN ('#{single_ident_values.join("','")}')
                AND trucking_destinations.country_code::text = '#{single_ident_values_and_country.first[:country]}'
            ),
            inserted_td_ids AS (
              INSERT INTO trucking_destinations(#{identifier_type}, country_code, created_at, updated_at)
                -- insert non-existent trucking_destinations
                SELECT ident_value, country_code::text, cr_at, up_at
                FROM (VALUES #{single_ident_values_and_country_with_timestamps})
                  AS t(ident_value, country_code, cr_at, up_at)
                WHERE ident_value NOT IN (
                  SELECT #{identifier_type}
                  FROM existing_identifiers
                  WHERE country_code::text = '#{single_ident_values_and_country.first[:country]}'
                )
              RETURNING id
            )          
          SELECT id FROM inserted_td_ids
          UNION
          SELECT id FROM existing_identifiers
        eos

        td_ids = ActiveRecord::Base.connection.execute(td_query).values.flatten
        
        with_statement = <<-eos
          WITH
            td_ids AS (SELECT id from trucking_destinations WHERE id IN #{td_ids.sql_format}),
            matching_tps_without_rates_and_fees AS (
              SELECT trucking_pricings.id, #{new_cols.join(", ")}
              FROM td_ids
              JOIN hub_truckings ON td_ids.id::integer = hub_truckings.trucking_destination_id::integer
              JOIN trucking_pricings ON trucking_pricings.id::integer = hub_truckings.trucking_pricing_id::integer
            ),
            hub_ids AS (
              VALUES(#{hub_id})
            ),
            t_stamps AS (
              VALUES(current_timestamp)
            ),
            tp AS (
              SELECT * FROM (
                VALUES #{tp.to_postgres_insertable(new_cols)}
              ) AS t(#{new_cols.join(", ")})
            ),
            matching_tp_id_table AS (
              SELECT id FROM matching_tps_without_rates_and_fees
              INNER JOIN tp USING (#{new_cols.join(", ")})
            )
        eos

        insertion_query = <<-eos
          DO
          $do$
          BEGIN
          IF (
            #{with_statement}
            SELECT EXISTS(SELECT 1 FROM matching_tp_id_table)
          ) THEN
            #{with_statement}
            UPDATE trucking_pricings SET (fees, rates) = #{tp.to_postgres_insertable(%w(fees rates))}
            WHERE trucking_pricings.id IN (SELECT id FROM matching_tp_id_table);
          ELSE
            #{with_statement},
            tp_ids AS (
              INSERT INTO trucking_pricings(carriage, cbm_ratio, courier_id, fees, load_meterage, load_type, modifier, rates, tenant_id, truck_type)
                VALUES #{tp.to_postgres_insertable}
              RETURNING id
            )
            INSERT INTO hub_truckings(hub_id, trucking_pricing_id, trucking_destination_id, created_at, updated_at)
              (
                SELECT * FROM hub_ids
                CROSS JOIN tp_ids
                CROSS JOIN td_ids
                CROSS JOIN t_stamps AS created_ats
                CROSS JOIN t_stamps AS updated_ats
              );
          END IF;        
          END
          $do$
        eos

        ActiveRecord::Base.connection.execute(insertion_query)
      end
    end
    # END Rates ------------------------

    { results: results, stats: stats }
  end

  def overwrite_city_trucking_rates_by_hub(params, _user = current_user, hub_id, courier_name, direction)
    courier = Courier.find_or_create_by(name: courier_name)
    p direction
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
      weight_cat_row = first_sheet.row(2)
      num_rows = first_sheet.last_row

      [3, 4, 5, 6].each do |i|
        min_max_arr = weight_cat_row[i].split(' - ')
        defaults.push(min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil)
      end

      (3..num_rows).each do |line|
        row_data = first_sheet.row(line)
        new_pricing = {}

        new_pricing[:city] = {
          province: row_data[0].downcase,
          city: row_data[1].downcase,
          dist_hub: row_data[2].split(' , ')
        }
        new_pricing[:currency] = 'CNY'
        new_pricing[:tenant_id] = user.tenant_id
        new_pricing[:nexus_id] = nexus.id
        new_pricing[:trucking_hub_id] = trucking_table_id
        new_pricing[:delivery_eta_in_days] = row_data[10]
        new_pricing[:modifier] = 'kg'
        new_pricing[:direction] = direction
        ntp = new_pricing
        ntp[:_id] = SecureRandom.uuid
        td = TruckingDestination.find_or_create_by!(city_name: Location.get_trucking_city("#{row_data[1]}, #{row_data[0]}"), country_code: 'CN')
        hub_trucking = HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id)
        new_pricing[direction] = { 'table' => [] }
        ntp = new_pricing
        ntp[:truck_type] = 'default'

        [3, 4, 5, 6].each do |i|
          tmp = defaults[i - 3].clone
          tmp[:delivery_eta_in_days] = row_data[10]
          ntp[:modifier] = 'kg'
          tmp[:type] = 'default'
          tmp[:cbm_ratio] = 250
          tmp[:fees] = {
            base_rate: {
              kg: row_data[i],
              cbm: row_data[7],
              rate_basis: 'PER_CBM_KG',
              currency: 'CNY'
            },
            vat: {
              value: 0.06,
              rate_basis: 'PERCENTAGE',
              currency: 'CNY'
            }
          }
          if direction === 'export'
            tmp[:fees][:PUF] = { value: row_data[8], currency: new_pricing[:currency], rate_basis: 'PER_SHIPMENT' }
          else
            tmp[:fees][:DLF] = { value: row_data[9], currency: new_pricing[:currency], rate_basis: 'PER_SHIPMENT' }
          end

          ntp[:load_type] = load_type
          ntp[:tenant_id] = hub.tenant_id
          ntp[direction]['table'] << tmp
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

    { stats: stats, results: results }
  end

  def overwrite_local_charges(params, user = current_user)
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
          direction: 'DIRECTION',
          currency: 'CURRENCY',
          rate_basis: 'RATE_BASIS',
          ton: 'TON',
          cbm: 'CBM',
          kg: 'KG',
          item: 'ITEM',
          shipment: 'SHIPMENT',
          bill: 'BILL',
          container: 'CONTAINER',
          minimum: 'MINIMUM',
          wm: 'WM',
          effective_date: 'EFFECTIVE_DATE',
          expiration_date: 'EXPIRATION_DATE'
        )
        if rows.length < 1
          next 
        end
        %w[lcl fcl_20 fcl_40 fcl_40_hq].each do |lt|
          hub_fees[lt] = {
            'import' => {},
            'export' => {},
            'mode_of_transport' => rows[0][:mot].downcase,
            'tenant_id' => hub.tenant_id,
            'hub_id' => hub.id,
            'load_type' => lt
          }
          customs[lt] = {
            'import' => {},
            'export' => {},
            'tenant_id' => hub.tenant_id,
            'hub_id' => hub.id,
            'mode_of_transport' => rows[0][:mot].downcase,
            'load_type' => lt
          }
        end

        rows.each do |row|
          case row[:rate_basis]
          when "PER_SHIPMENT"
            charge = {currency: row[:currency], value: row[:shipment], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_CONTAINER"
            charge = {currency: row[:currency], value: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_BILL"
            charge = {currency: row[:currency], min: row[:minimum], value: row[:bill], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_CBM"
            charge = {currency: row[:currency], min: row[:minimum], value: row[:cbm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_KG"
            charge = {currency: row[:currency], min: row[:minimum], value: row[:kg], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_TON"
            charge = {currency: row[:currency], ton: row[:ton], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_WM"
            charge = {currency: row[:currency], value: row[:wm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_ITEM"
            charge = {currency: row[:currency], value: row[:item], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_CBM_TON"
            charge = {currency: row[:currency], cbm: row[:cbm], ton: row[:ton], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_SHIPMENT_CONTAINER"
            charge = {currency: row[:currency], shipment: row[:shipment], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_BILL_CONTAINER"
            charge = {currency: row[:currency], bill: row[:bill], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_CBM_KG"
            charge = {currency: row[:currency], cbm: row[:cbm], kg: row[:kg], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          end

          charge[:expiration_date] = row[:expiration_date]
          charge[:effective_date] = row[:effective_date]

          if row[:fee_code] != 'CUST'
            hub_fees = local_charge_load_setter(hub_fees, charge, row[:load_type].downcase, row[:direction].downcase, sheet_name)
          else
            customs = local_charge_load_setter(customs, charge, row[:load_type].downcase, row[:direction].downcase, sheet_name)
          end
        end
      end

      hub_fees.each do |k, v|
        lc = hub.local_charges.find_by(mode_of_transport: v['mode_of_transport'], load_type: k)
        if lc
          lc.update_attributes(v)
        else
          hub.local_charges.create!(v)
        end
        results[:charges] << v
        stats[:charges][:number_updated] += 1
      end
      customs.each do |k, v|
        cf = hub.customs_fees.find_by(mode_of_transport: v['mode_of_transport'], load_type: k)
        if cf
          cf.update_attributes(v)
        else
          hub.customs_fees.create!(v)
        end

        results[:customs] << v
        stats[:customs][:number_updated] += 1
      end
    end
    { stats: stats, results: results }
  end

  def overwrite_schedules_by_itinerary(params, user = current_user)
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
      voyage_code: 'VOYAGE_CODE',
      from: 'FROM',
      to: 'TO',
      closing_date: 'CLOSING_DATE',
      eta: 'ETA',
      etd: 'ETD',
      service_level: 'SERVICE_LEVEL'
    )

    schedules.each do |row|
      itinerary = params["itinerary"]
      service_level = row[:service_level] ? row[:service_level] : "default"

      tenant_vehicle = TenantVehicle.find_by(
        tenant_id: user.tenant_id,
        mode_of_transport: itinerary.mode_of_transport,
        name: row[:service_level],
      )
      tenant_vehicle ||= Vehicle.create_from_name(service_level, itinerary.mode_of_transport, user.tenant_id)

      startDate = row[:etd]
      endDate = row[:eta]

      stops = itinerary.stops.order(:index)

      if itinerary
        generator_results = itinerary.generate_schedules_from_sheet(stops, startDate, endDate, tenant_vehicle.vehicle_id, row[:closing_date], row[:vessel], row[:voyage_code])
        results[:trips] = generator_results[:trips]
        results[:layovers] = generator_results[:layovers]
        stats[:trips][:number_created] = generator_results[:trips].count
        stats[:layovers][:number_created] = generator_results[:layovers].count
      else
        raise "Route cannot be found!"
      end
    end

    {results: results, stats: stats}
  end

  def overwrite_all_schedules(params, user = current_user)
    stats = {
      type: "schedules",
      layovers: {
        number_updated: 0,
        number_created: 0,
      },
      trips: {
        number_updated: 0,
        number_created: 0,
      },
    }

    results = {
      layovers: [],
      trips: [],
    }
    xlsx = Roo::Spreadsheet.open(params["xlsx"])
    first_sheet = xlsx.sheet(xlsx.sheets.first)

    schedules = first_sheet.parse(
      vessel: "VESSEL",
      voyage_code: "VOYAGE_CODE",
      from: "FROM",
      to: "TO",
      closing_date: "CLOSING_DATE",
      eta: "ETA",
      etd: "ETD",
      service_level: "SERVICE_LEVEL"
    )
    mot = params["mot"]

    schedules.each do |row|
      itinerary = Itinerary.find_by(name: "#{row[:from]} - #{row[:to]}", mode_of_transport: mot)
      if !itinerary
        next
      end
      service_level = row[:service_level] ? row[:service_level] : "default"

      tenant_vehicle = TenantVehicle.find_by(
        tenant_id: user.tenant_id,
        mode_of_transport: itinerary.mode_of_transport,
        name: row[:service_level]
      )
      tenant_vehicle ||= Vehicle.create_from_name(service_level, itinerary.mode_of_transport, user.tenant_id)

      startDate = row[:etd]
      endDate = row[:eta]

      stops = itinerary.stops.order(:index)

      if itinerary
        generator_results = itinerary.generate_schedules_from_sheet(stops, startDate, endDate, tenant_vehicle_id, row[:closing_date], row[:vessel], row[:voyage_code])
        results[:trips] = generator_results[:trips]
        results[:layovers] = generator_results[:layovers]
        stats[:trips][:number_created] = generator_results[:trips].count
        stats[:layovers][:number_created] = generator_results[:layovers].count
      else
        raise 'Route cannot be found!'
      end
    end

    { results: results, stats: stats }
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
    hub_rows = first_sheet.parse(hub_status: 'STATUS', hub_type: 'TYPE', hub_name: 'NAME', hub_code: 'CODE', latitude: 'LATITUDE', longitude: 'LONGITUDE', country: 'COUNTRY', geocoded_address: 'FULL_ADDRESS', photo: 'PHOTO')

    hub_type_name = {
      'ocean' => 'Port',
      'air' => 'Airport',
      'rail' => 'Railway Station'
    }

    hub_rows.map do |hub_row|
      hub_row[:hub_type] = hub_row[:hub_type].downcase
      nexus = Location.find_by(
        name: hub_row[:hub_name],
        location_type: 'nexus',
        country: hub_row[:country]
      )
      nexus ||= Location.create!(
        name: hub_row[:hub_name],
        location_type: 'nexus',
        latitude: hub_row[:latitude],
        longitude: hub_row[:longitude],
        photo: hub_row[:photo],
        country: hub_row[:country],
        city: hub_row[:hub_name],
        geocoded_address: hub_row[:geocoded_address]
      )

      location = Location.find_or_create_by(
        name: hub_row[:hub_name],
        latitude: hub_row[:latitude],
        longitude: hub_row[:longitude],
        country: hub_row[:country],
        city: hub_row[:hub_name],
        geocoded_address: hub_row[:geocoded_address]
      )
      hub_code = hub_row[:hub_code] unless hub_row[:hub_code].blank?

      hub = Hub.find_by(
        nexus_id: nexus.id,
        tenant_id: user.tenant_id,
        hub_type: hub_row[:hub_type],
        name: "#{nexus.name} #{hub_type_name[hub_row[:hub_type]]}"
      )

      if hub
        hub.update_attributes(
          nexus_id: nexus.id,
          location_id: location.id,
          tenant_id: user.tenant_id,
          hub_type: hub_row[:hub_type],
          trucking_type: hub_row[:trucking_type],
          latitude: hub_row[:latitude],
          longitude: hub_row[:longitude],
          name: "#{nexus.name} #{hub_type_name[hub_row[:hub_type]]}",
          photo: hub_row[:photo]
        )

        results[:hubs] << hub
        stats[:hubs][:number_updated] += 1
      else
        hub = nexus.hubs.create!(
          nexus_id: nexus.id,
          location_id: location.id,
          tenant_id: user.tenant_id,
          hub_type: hub_row[:hub_type],
          trucking_type: hub_row[:trucking_type],
          latitude: hub_row[:latitude],
          longitude: hub_row[:longitude],
          name: "#{nexus.name} #{hub_type_name[hub_row[:hub_type]]}",
          photo: hub_row[:photo]
        )
        results[:hubs] << hub
        stats[:hubs][:number_created] += 1
      end

      results[:nexuses] << nexus
      stats[:nexuses][:number_updated] += 1

      hub.generate_hub_code!(user.tenant_id) unless hub.hub_code
      hub
    end
    { stats: stats, results: results }
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

  def overwrite_freight_rates(params, user = current_user, generate = false)
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
      transit_time: 'TRANSIT_TIME',
      carrier: 'CARRIER',
      nested: 'NESTED',
      wm_rate: 'WM_RATE'
    )

    tenant = user.tenant
    aux_data = {}
    new_pricings = {}
    nested_pricings = {}

    pricing_rows.each do |row|
      pricing_key = "#{row[:origin].gsub(/\s+/, '').gsub(/,+/, '')}_#{row[:destination].gsub(/\s+/, '').gsub(/,+/, '')}_#{row[:mot]}"
      new_pricings[pricing_key] = {} unless new_pricings[pricing_key]

      effective_date = DateTime.parse(row[:effective_date].to_s)
      expiration_date = DateTime.parse(row[:expiration_date].to_s)
      cargo_type = row[:cargo_type]

      new_pricings[pricing_key][cargo_type] ||= {
        data: {},
        exceptions: [],
        effective_date: effective_date,
        expiration_date: expiration_date,
        updated_at: DateTime.now
      }

      aux_data[pricing_key] ||= {}

      if aux_data[pricing_key][:tenant_vehicle].blank?
        vehicle = TenantVehicle.find_by(name: row[:vehicle], mode_of_transport: row[:mot])
        aux_data[pricing_key][:tenant_vehicle] = vehicle.presence || Vehicle.create_from_name(row[:vehicle], row[:mot], tenant.id)
      end

      aux_data[pricing_key][:customer] = User.find(row[:customer_id]) if row[:customer_id]
      aux_data[pricing_key][:transit_time] ||= row[:transit_time]
      aux_data[pricing_key][:origin] ||= Location.find_by(name: row[:origin], location_type: 'nexus')
      aux_data[pricing_key][:destination] ||= Location.find_by(name: row[:destination], location_type: 'nexus')
      aux_data[pricing_key][:origin_hub_ids] ||= aux_data[pricing_key][:origin].hubs_by_type(row[:mot], user.tenant_id).ids
      aux_data[pricing_key][:destination_hub_ids] ||= aux_data[pricing_key][:destination].hubs_by_type(row[:mot], user.tenant_id).ids
      aux_data[pricing_key][:hub_ids] = aux_data[pricing_key][:origin_hub_ids] + aux_data[pricing_key][:destination_hub_ids]

      if aux_data[pricing_key][:itinerary].blank?
        itinerary_name = "#{aux_data[pricing_key][:origin].name} - #{aux_data[pricing_key][:destination].name}"
        itinerary = tenant.itineraries.find_by(mode_of_transport: row[:mot], name: itinerary_name)
        if itinerary.blank?
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
        else
          temp_stop = aux_data[pricing_key][:itinerary].stops.create!(hub_id: h, index: i)
          stats[:stops][:number_created] += 1
        end
        results[:stops] << temp_stop
        temp_stop
      end

      steps_in_order = []
      aux_data[pricing_key][:stops_in_order].length.times do
        steps_in_order << aux_data[pricing_key][:transit_time].to_i
      end

      start_date = DateTime.now
      end_date = start_date + 30.days

      if generate
        generator_results = aux_data[pricing_key][:itinerary].generate_weekly_schedules(
          aux_data[pricing_key][:stops_in_order],
          steps_in_order,
          start_date,
          end_date,
          [1, 5],
          aux_data[pricing_key][:tenant_vehicle].id
        )
        results[:layovers] = generator_results[:results][:layovers]
        results[:trips] = generator_results[:results][:trips]
        stats[:layovers][:number_created] = generator_results[:results][:layovers].length
        stats[:trips][:number_created] = generator_results[:results][:trips].length
      end

      if row[:nested].present?
        nested_key = "#{effective_date.to_i}_#{aux_data[pricing_key][:itinerary].id}"
        nested_pricings[pricing_key] ||= { cargo_type.to_s => {} }

        nested_pricings[pricing_key][cargo_type][nested_key] ||= {
          data: {},
          effective_date: effective_date,
          expiration_date: expiration_date
        }
        nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]] ||= {
          rate: row[:rate],
          rate_basis: row[:rate_basis],
          currency: row[:currency]
        }

        if row[:hw_threshold]
          nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:hw_threshold] = row[:hw_threshold]
        end

        if row[:hw_rate_basis]
          nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:hw_rate_basis] = row[:hw_rate_basis]
        end

        if row[:min_range]
          nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]].delete('rate')
          nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:range] ||= []
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
        unless new_pricings[pricing_key][cargo_type][:data][row[:fee]]
          
          new_pricings[pricing_key][cargo_type][:data][row[:fee]] = {
            rate: row[:rate],
            rate_basis: row[:rate_basis],
            currency: row[:currency],
            min_value: row[:rate_min]
          }
        end

        new_pricings[pricing_key][cargo_type][:wm_rate] = row[:wm_rate]

        if row[:hw_threshold]
          new_pricings[pricing_key][cargo_type][:data][row[:fee]][:hw_threshold] = row[:hw_threshold]
        end

        if row[:hw_rate_basis]
          new_pricings[pricing_key][cargo_type][:data][row[:fee]][:hw_rate_basis] = row[:hw_rate_basis]
        end

        if row[:min_range]
          new_pricings[pricing_key][cargo_type][:data][row[:fee]].delete('rate')
          new_pricings[pricing_key][cargo_type][:data][row[:fee]][:range] ||= []
          new_pricings[pricing_key][cargo_type][:data][row[:fee]][:range] << {
            min: row[:min_range],
            max: row[:max_range],
            rate: row[:rate]
          }
        end
      end
    end

    nested_pricings.each do |p_key, cargo_values|
      cargo_values.each do |c_key, nested_values|
        nested_values.each do |_n_key, value|
          new_pricings[p_key][c_key][:exceptions] << value
        end
      end
    end

    new_pricings.each do |it_key, cargo_pricings|
      cargo_pricings.each do |cargo_key, pricing_data|
        new_pricing_data = pricing_data.clone()
        transport_category = aux_data[it_key][:tenant_vehicle].vehicle.transport_categories.find_by(name: 'any', cargo_class: cargo_key)
        itinerary = aux_data[it_key][:itinerary]
        user = aux_data[it_key][:customer]

        pricing = itinerary.pricings.find_or_create_by!(transport_category: transport_category, tenant: tenant, user: user)

        pricing_details = new_pricing_data.delete(:data)
        pricing_exceptions = new_pricing_data.delete(:exceptions)
        # external_updated_at = pricing_data.delete(:updated_at)
        pricing.update(new_pricing_data)
        pricing_details.each do |shipping_type, pricing_detail_data|
          currency = pricing_detail_data.delete(:currency)
          pricing_detail_params = pricing_detail_data.merge(shipping_type: shipping_type, tenant: tenant)
          range = pricing_detail_params.delete(:range)
          pricing_detail = pricing.pricing_details.where(pricing_detail_params).first_or_create!(pricing_detail_params)
          pricing_detail.update!(range: range, currency_name: currency) #, external_updated_at: external_updated_at)
        end

        pricing_exceptions.each do |pricing_exception_data|
          pricing_details = pricing_exception_data.delete(:data)
          pricing_exception = pricing.pricing_exceptions.where(pricing_exception_data).first_or_create(pricing_exception_data.merge(tenant: tenant))
          pricing_details.each do |shipping_type, pricing_detail_data|
            currency = pricing_detail_data.delete(:currency)
            range = pricing_detail_data.delete(:range)
            pricing_detail_params = pricing_detail_data.merge(shipping_type: shipping_type, tenant: tenant)
            pricing_detail = pricing_exception.pricing_details.where(pricing_detail_params).first_or_create!(pricing_detail_params)
            pricing_detail.update!(range: range, currency_name: currency)
          end
        end


        if aux_data[it_key][:customer].present?
          results[:userPricings] << pricing
          stats[:userPricings][:number_created] += 1
        end

        stats[:pricings][:number_created] += 1
        results[:pricings] << pricing
      end
    end
    tenant.update_route_details # TODO: check if necessary
    { results: results, stats: stats }
  end

  def price_split(basis, string)
    vals = string.split(' ')
    {
      'currency' => vals[1],
      'rate' => vals[0].to_i,
      'rate_basis' => basis
    }
  end

  def rate_key(cargo_class)
    base_str = cargo_class.dup
    base_str.slice! cargo_class.rindex('f')
    "#{base_str}_rate".to_sym
  end

  def local_charge_load_setter(all_charges, charge, load_type, direction, test)
    debug_message(charge)
    debug_message(all_charges)

    if load_type === 'fcl'
      %w[fcl_20 fcl_40 fcl_40_hq].each do |lt|
        debug_message(test)
        debug_message(all_charges[lt])
        debug_message(all_charges[lt][direction])
        debug_message(charge)

        all_charges[lt][direction][charge[:key]] = charge
      end
    else
      all_charges[load_type][direction][charge[:key]] = charge
    end
    all_charges
  end

  def debug_message(message)
    puts message if DEBUG
  end
end
