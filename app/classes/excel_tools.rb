# frozen_string_literal: true

module ExcelTools
  include ImageTools
  include MongoTools
  include PricingTools

  def handle_zipcode_sections(rows, _user, direction, hub_id, courier_name, load_type, defaults, weight_min_row, meta)
    courier = Courier.find_or_create_by(name: courier_name)
    rows.each do |row_data|
      zip_code_range_array = row_data.shift.split(" - ")
      zip_code_range = (zip_code_range_array[0].to_i...zip_code_range_array[1].to_i)
      row_min_value = row_data.shift

      trucking_pricing = TruckingPricing.new(
        export: {table: []},
        import: {table: []},
        load_type: meta[:load_type],
        load_meterage: {
          ratio: meta[:load_meterage_ratio],
          height_limit: 130,
        },
        cbm_ratio: meta[:cbm_ratio],
        courier: courier,
        modifier: meta[:modifier],
        truck_type: "default",
      )

      trucking_pricing[direction]["table"] = row_data.map.with_index do |val, i|
        next if !val || !weight_min_row[i]

        defaults[i].clone.merge(
          min_value: [weight_min_row[i], row_min_value].max,
          fees: {
            base_rate: {
              value: val,
              rate_basis: "PER_X_KG",
              currency: meta[:currency],
              base: 100,
            },
            congestion: {
              value: 15,
              rate_basis: "PER_SHIPMENT",
              currency: meta[:currency],
            },
          },
        )
      end

      trucking_pricing_should_update = nil

      zip_code_range.each do |zipcode|
        p zipcode
        trucking_destination = TruckingDestination.find_by!(zipcode: zipcode, country_code: "SE")

        trucking_pricing_ids = TruckingPricing.where(
          load_type: load_type,
          truck_type: "default",
          load_meterage: {
            ratio: meta[:load_meterage_ratio],
            height_limit: 130,
          },
          modifier: meta[:modifier],
        ).ids

        hub_trucking = HubTrucking.where(
          trucking_destination: trucking_destination,
          trucking_pricing_id: trucking_pricing_ids,
          hub_id: hub_id,
        ).first

        if hub_trucking.nil?
          trucking_pricing.save!
          HubTrucking.create(
            trucking_destination: trucking_destination,
            trucking_pricing: trucking_pricing,
            hub_id: hub_id,
          )
        else
          trucking_pricing_should_update = hub_trucking.trucking_pricing
        end
      end

      trucking_pricing_should_update.try(:update, direction => {"table" => trucking_pricing[direction]["table"]})
    end
  end

  def split_zip_code_sections(params, user = current_user, hub_id, courier_name, direction)
    defaults = []
    load_type = "cargo_item"
    no_of_jobs = 10
    xlsx = Roo::Spreadsheet.open(params["xlsx"])

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
        min_max_arr = cell.split(" - ")
        defaults.push(min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil)
      end

      rows_for_job.each do |rfj|
        job_id = SecureRandom.uuid
        update_item("jobs", {_id: job_id}, completed: false, created: DateTime.now)

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
            base: base,
          },
        }

        ExcelWorker.perform_async(worker_obj)
      end
    end

    # handle_zipcode_sections(test_array[0][:rows_for_job], user, test_array[0][:direction], test_array[0][:hub_id], test_array[0][:courier_name], test_array[0][:load_type], test_array[0][:defaults], test_array[0][:weight_min_row], test_array[0][:currency])
  end

  def overwrite_zipcode_trucking_rates_by_hub(params, _user = current_user, hub_id, courier_name, direction)
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

    courier = Courier.find_or_create_by(name: courier_name)
    defaults = []
    load_type = "cargo_item"

    xlsx = Roo::Spreadsheet.open(params["xlsx"])
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

        min_max_arr = cell.split(" - ")
        defaults.push(min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil)
      end

      (4..num_rows).each do |line|
        row_data = first_sheet.row(line)
        zip_code_range_array = row_data.shift.split(" - ")
        # zip_code_range = (zip_code_range_array[0].to_i..zip_code_range_array[1].to_i)
        row_min_value = row_data.shift
        # ntp = TruckingPricing.new(currency: currency_row[3], tenant_id: user.tenant_id, nexus_id: nexus.id, lower_zip: zip_code_range_array[0].to_i, upper_zip: zip_code_range_array[1].to_i)
        zip_codes = []
        hub_truckings = []
        tmp_zip = zip_code_range_array[0].to_i

        while tmp_zip <= zip_code_range_array[1].to_i
          td = TruckingDestination.find_by!(zipcode: tmp_zip, country_code: "SE")
          zip_codes << td
          hub_truckings << HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id)
          tmp_zip += 1
          p tmp_zip
        end

        if hub_truckings[0].trucking_pricing_id
          trucking_pricing = hub_truckings[0].trucking_pricing
        else
          trucking_pricing = courier.trucking_pricings.create!(tenant_id: hub.tenant_id, export: {table: []}, import: {table: []}, load_type: load_type)
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
              rate_basis: "PER_X_KG",
              currency: currency_row[3],
              base: 100,
            },
          }

          if direction == "export"
            tmp[:fees][:congestion] = {
              value: 15,
              rate_basis: "PER_ITEM",
              currency: currency_row[3],
            }
          end

          if direction == "import"
            tmp[:fees][:congestion] = {
              value: 15,
              rate_basis: "PER_ITEM",
              currency: currency_row[3],
            }
          end

          tmp[:direction] = direction
          tmp[:type] = "default"
          trucking_pricing["load_meterage"] = {
            ratio: 1950,
            height_limit: 130,
          }

          trucking_pricing[:modifier] = "kg"
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

    {results: results, stats: stats}
  end

  def overwrite_zonal_trucking_rates_by_hub(params, _user = current_user, hub_id)
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
    
    defaults = {}
    load_type = "cargo_item"
    trucking_pricing_by_zone = {}
    hub = Hub.find(hub_id)
    tenant = hub.tenant
    xlsx = Roo::Spreadsheet.open(params["xlsx"])
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
    identifier = zone_sheet.row(10)[7] == 'city' ? 'city_name' : zone_sheet.row(10)[7]
    courier = Courier.find_or_create_by(name: zone_sheet.row(9)[7])
    num_rows = zone_sheet.last_row

    zones = {}

    (2..num_rows).each do |line|
      row_data = zone_sheet.row(line)
      row_data[0] = row_data[0].to_s
      zones[row_data[0]] = [] unless zones[row_data[0]]

      if row_data[1] && !row_data[2]
        zones[row_data[0]] << {id: row_data[1], country: row_data[3]}
      elsif !row_data[1] && row_data[2]
        range = row_data[2].delete!(" ").split("-")
        zones[row_data[0]] << {min: range[0].to_d, max: range[1].to_d, country: row_data[3]}
      end
    end

    fees_sheet = xlsx.sheet(sheets[2])

    rows = fees_sheet.parse(
      fee: "FEE",
      mot: "MOT",
      fee_code: "FEE_CODE",
      truck_type: "TRUCK_TYPE",
      direction: "DIRECTION",
      currency: "CURRENCY",
      rate_basis: "RATE_BASIS",
      ton: "TON",
      cbm: "CBM",
      kg: "KG",
      item: "ITEM",
      shipment: "SHIPMENT",
      bill: "BILL",
      container: "CONTAINER",
      minimum: "MINIMUM",
      wm: "WM",
    )

    charges = {}

    rows.each do |row|
      case row[:rate_basis]
      when "PER_SHIPMENT"
        charges[row[:fee_code]] = {truck_type: row[:truck_type], currency: row[:currency], value: row[:shipment], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
      when "PER_CONTAINER"
        charges[row[:fee_code]] = {truck_type: row[:truck_type], currency: row[:currency], value: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
      when "PER_BILL"
        charges[row[:fee_code]] = {truck_type: row[:truck_type], currency: row[:currency], value: row[:bill], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
      when "PER_CBM"
        charges[row[:fee_code]] = {truck_type: row[:truck_type], currency: row[:currency], value: row[:cbm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
      when "PER_KG"
        charges[row[:fee_code]] = {truck_type: row[:truck_type], currency: row[:currency], value: row[:cbm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
      when "PER_WM"
        charges[row[:fee_code]] = {truck_type: row[:truck_type], currency: row[:currency], value: row[:wm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
      when "PER_ITEM"
        charges[row[:fee_code]] = {truck_type: row[:truck_type], currency: row[:currency], value: row[:item], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
      when "PER_CBM_TON"
        charges[row[:fee_code]] = {truck_type: row[:truck_type], currency: row[:currency], cbm: row[:cbm], ton: row[:ton], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
      when "PER_SHIPMENT_CONTAINER"
        charges[row[:fee_code]] = {truck_type: row[:truck_type], currency: row[:currency], shipment: row[:shipment], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
      when "PER_BILL_CONTAINER"
        charges[row[:fee_code]] = {truck_type: row[:truck_type], currency: row[:currency], bill: row[:bill], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
      when "PER_CBM_KG"
        charges[row[:fee_code]] = {truck_type: row[:truck_type], currency: row[:currency], cbm: row[:cbm], kg: row[:kg], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
      end
    end

    rates_sheet = xlsx.sheet(sheets[1])
    rate_num_rows = rates_sheet.last_row
    modifier_indexes = {}
    modifier_row = rates_sheet.row(1)
    modifier_row.shift
    modifier_row.shift
    modifier_row.shift
    modifier_row.uniq.each do |mod|
      modifier_indexes[mod] = modifier_row.each_index.select { |index| modifier_row[index] == mod}
    end
    header_row = rates_sheet.row(2)
    header_row.shift
    header_row.shift
    header_row.shift

    weight_min_row = rates_sheet.row(3)
    weight_min_row.shift
    weight_min_row.shift
    weight_min_row.shift
    modifier_indexes.each do |mod_key, mod_indexes|
      header_row.each_with_index do |cell, i|
        if !cell || !mod_indexes.include?(i)
          next
        end
        if !defaults[mod_key]
          defaults[mod_key] = {}
        end
        min_max_arr = cell.split(" - ")
        defaults[mod_key][i] = {"min_#{mod_key}": min_max_arr[0].to_i, "max_#{mod_key}": min_max_arr[1].to_i, min_value: nil}.symbolize_keys
      end
    end

    (4..rate_num_rows).each do |line|
      row_data = rates_sheet.row(line)
      row_zone = row_data.shift
      row_truck_type = row_data.shift

      row_truck_type = "default" if !row_truck_type || row_truck_type == ""

      row_min_value = row_data.shift
      %w(import export).each do |direction|
        trucking_pricing_by_zone[row_zone] = TruckingPricing.new(
          rates: {},
          fees: {},
          direction: direction,
          load_type: load_type,
          load_meterage: {
            ratio:  load_meterage_ratio,
            height_limit: 130
          },
          cbm_ratio:  cbm_ratio,
          courier: courier,
          modifier:  modifier,
          truck_type: row_truck_type,
          tenant_id: tenant.id
        )
        modifier_indexes.each do |mod_key, mod_indexes|
          trucking_pricing_by_zone[row_zone].rates[mod_key] = mod_indexes.map do |m_index|
            val = row_data[m_index]
            if !val
              next
            end
            w_min = weight_min_row[m_index] || 0
            r_min = row_min_value || 0
            mod_cell = defaults[mod_key][m_index].clone.merge({
              min_value: [w_min, r_min].max,
              rate: {
                value: val,
                rate_basis: rate_basis,
                currency: currency,
                base: base
              }
            })
          end
        end

        charges.each do |k, fee|
          if fee[:direction] == direction
            fee.delete("direction")
            trucking_pricing_by_zone[row_zone][:fees][k] = fee
          end
        end
        awesome_print trucking_pricing_by_zone[row_zone]
      end

      trucking_pricing_should_update = nil
      zones.each do |key, identifiers|
        identifiers.each do |ident|
          if ident[:min] && ident[:max]
            ids = (ident[:min].to_i...ident[:max].to_i)
          else
            ids = [ident[:id]]
          end
          ids.each do |id|
            if identifier == 'city_name'
              trucking_destination = TruckingDestination.find_or_create_by!(identifier => Location.get_trucking_city("#{id.to_s}, #{ident[:country]}"), country_code: ident[:country])
            else
              trucking_destination = TruckingDestination.find_or_create_by!(identifier => id.to_s, country_code: ident[:country])
            end
            trucking_pricing_ids = TruckingPricing.where(
              load_type: load_type,
              truck_type: row_truck_type,
              load_meterage: {
                ratio: load_meterage_ratio,
                height_limit: load_meterage_limit,
              },
              modifier: modifier,
            ).ids

            hub_trucking = HubTrucking.where(
              trucking_destination: trucking_destination,
              trucking_pricing_id: trucking_pricing_ids,
              hub_id: hub_id,
            ).first

            if hub_trucking.nil?
              trucking_pricing_by_zone[row_zone].save!
              HubTrucking.create(
                trucking_destination: trucking_destination,
                trucking_pricing: trucking_pricing_by_zone[row_zone],
                hub_id: hub_id,
              )
            else
              trucking_pricing_should_update = hub_trucking.trucking_pricing
            end
            trucking_pricing_should_update.try(:update,
              trucking_pricing_by_zone[row_zone].given_attributes
            )
            # stats[:trucking_queries][:number_updated] += 1
          end
        end
      end
    end

    {results: results, stats: stats}
  end

  def overwrite_city_trucking_rates_by_hub(params, _user = current_user, hub_id, courier_name, direction)
    courier = Courier.find_or_create_by(name: courier_name)
    p direction
    defaults = []
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

    load_type = "cargo_item"
    xlsx = Roo::Spreadsheet.open(params["xlsx"])
    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      hub = Hub.find(hub_id)
      weight_cat_row = first_sheet.row(2)
      num_rows = first_sheet.last_row

      [3, 4, 5, 6].each do |i|
        min_max_arr = weight_cat_row[i].split(" - ")
        defaults.push(min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil)
      end

      (3..num_rows).each do |line|
        row_data = first_sheet.row(line)
        new_pricing = {}
        td = TruckingDestination.find_or_create_by!(city_name: Location.get_trucking_city("#{row_data[1]}, #{row_data[0]}"), country_code: "CN")
        hub_trucking = HubTrucking.find_or_initialize_by(trucking_destination_id: td.id, hub_id: hub.id)
        new_pricing[direction] = {"table" => []}
        ntp = new_pricing
        ntp[:truck_type] = "default"

        [3, 4, 5, 6].each do |i|
          tmp = defaults[i - 3].clone
          tmp[:delivery_eta_in_days] = row_data[10]
          ntp[:modifier] = "kg"
          tmp[:type] = "default"
          tmp[:cbm_ratio] = 250
          tmp[:fees] = {
            base_rate: {
              kg: row_data[i],
              cbm: row_data[7],
              rate_basis: "PER_CBM_KG",
              currency: "CNY",
            },
            vat: {
              value: 0.06,
              rate_basis: "PERCENTAGE",
              currency: "CNY",
            },
          }

          if direction === "export"
            tmp[:fees][:PUF] = {value: row_data[8], currency: new_pricing[:currency], rate_basis: "PER_SHIPMENT"}
          else
            tmp[:fees][:DLF] = {value: row_data[9], currency: new_pricing[:currency], rate_basis: "PER_SHIPMENT"}
          end

          ntp[:load_type] = load_type
          ntp[:tenant_id] = hub.tenant_id
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

    {stats: stats, results: results}
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

  def overwrite_local_charges(params, user = current_user)
    mongo = get_client

    stats = {
      type: "local_charges",
      charges: {
        number_updated: 0,
        number_created: 0,
      },
      customs: {
        number_updated: 0,
        number_created: 0,
      },
    }

    results = {
      charges: [],
      customs: [],
    }

    local_charges = []
    customs_fees = []
    xlsx = Roo::Spreadsheet.open(params["xlsx"])

    xlsx.sheets.each do |sheet_name|
      first_sheet = xlsx.sheet(sheet_name)
      hub = Hub.find_by(name: sheet_name, tenant_id: user.tenant_id)
      hub_fees = {}
      customs = {}

      if hub
        rows = first_sheet.parse(
          fee: "FEE",
          mot: "MOT",
          fee_code: "FEE_CODE",
          load_type: "LOAD_TYPE",
          direction: "DIRECTION",
          currency: "CURRENCY",
          rate_basis: "RATE_BASIS",
          ton: "TON",
          cbm: "CBM",
          kg: "KG",
          item: "ITEM",
          shipment: "SHIPMENT",
          bill: "BILL",
          container: "CONTAINER",
          minimum: "MINIMUM",
          wm: "WM",
          effective_date: "EFFECTIVE_DATE",
          expiration_date: "EXPIRATION_DATE",
        )

        %w[lcl fcl_20 fcl_40 fcl_40hq].each do |lt|
          hub_fees[lt] = {
            "import" => {},
            "export" => {},
            "mode_of_transport" => rows[0][:mot].downcase,
            "nexus_id" => hub.nexus.id,
            "tenant_id" => hub.tenant_id,
            "hub_id" => hub.id,
            "load_type" => lt,
          }
          customs[lt] = {
            "import" => {},
            "export" => {},
            "nexus_id" => hub.nexus.id,
            "tenant_id" => hub.tenant_id,
            "hub_id" => hub.id,
            "mode_of_transport" => rows[0][:mot].downcase,
            "load_type" => lt,
          }
        end

        rows.each do |row|
          case row[:rate_basis]
          when "PER_SHIPMENT"
            charge = {currency: row[:currency], value: row[:shipment], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_CONTAINER"
            charge = {currency: row[:currency], value: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_BILL"
            charge = {currency: row[:currency], value: row[:bill], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_CBM"
            charge = {currency: row[:currency], value: row[:cbm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
          when "PER_KG"
            charge = {currency: row[:currency], value: row[:cbm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee]}
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

          if row[:fee_code] != "CUST"
            hub_fees = local_charge_load_setter(hub_fees, charge, row[:load_type].downcase, row[:direction].downcase, sheet_name)
          else
            customs = local_charge_load_setter(customs, charge, row[:load_type].downcase, row[:direction].downcase, sheet_name)
          end
        end
      end

      hub_fees.each do |k, v|
        lc_id = "#{hub.id}_#{hub.tenant_id}_#{k}"
        local_charges.push(
          replace_one: {
            filter: {_id: lc_id},
            replacement: v,
            upsert: true,
          },
        )

        results[:charges] << v
        stats[:charges][:number_updated] += 1
        # update_item('localCharges', {"_id" => lc_id}, v)
      end

      customs.each do |k, v|
        lc_id = "#{hub.id}_#{hub.tenant_id}_#{k}"
        customs_fees.push(
          replace_one: {
            filter: {_id: lc_id},
            replacement: v,
            upsert: true,
          },
        )

        results[:customs] << v
        stats[:customs][:number_updated] += 1
        # update_item('customsFees', {"_id" => lc_id}, v)
      end
    end

    mongo["localCharges"].bulk_write(local_charges)
    mongo["customsFees"].bulk_write(customs_fees)

    {stats: stats, results: results}
  end

  def overwrite_schedules_by_itinerary(params, user = current_user)
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
      vpyage_code: "VOYAGE_CODE",
      from: "FROM",
      to: "TO",
      closing_date: "CLOSING_DATE",
      eta: "ETA",
      etd: "ETD",
      service_level: 'SERVICE_LEVEL'
    )

    schedules.each do |row|
      itinerary = params["itinerary"]
      service_level = row[:service_level] ? row[:service_level] : "default"

      tenant_vehicle = TenantVehicle.find_by(
          tenant_id: user.tenant_id, 
          mode_of_transport: itinerary.mode_of_transport,
          name: row[:service_level]
        )
        if !tenant_vehicle
          tenant_vehicle =  Vehicle.create_from_name(service_level, itinerary.mode_of_transport, user.tenant_id)
        end
        
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

  def overwrite_hubs(params, user = current_user)
    xlsx = Roo::Spreadsheet.open(params["xlsx"])
    first_sheet = xlsx.sheet(xlsx.sheets.first)

    stats = {
      type: "hubs",
      hubs: {
        number_updated: 0,
        number_created: 0,
      },
      nexuses: {
        number_updated: 0,
        number_created: 0,
      },
    }

    results = {
      hubs: [],
      nexuses: [],
    }

    hub_rows = first_sheet.parse(hub_status: "STATUS", hub_type: "TYPE", hub_name: "NAME", hub_code: "CODE", latitude: "LATITUDE", longitude: "LONGITUDE", country: "COUNTRY", geocoded_address: "FULL_ADDRESS", photo: "PHOTO")

    hub_type_name = {
      "ocean" => "Port",
      "air" => "Airport",
      "rail" => "Railway Station",
    }

    hub_rows.map do |hub_row|
      hub_row[:hub_type] = hub_row[:hub_type].downcase
      nexus = Location.find_by(
        name: hub_row[:hub_name],
        location_type: "nexus",
        country: hub_row[:country],
      )

      nexus ||= Location.create!(
        name: hub_row[:hub_name],
        location_type: "nexus",
        latitude: hub_row[:latitude],
        longitude: hub_row[:longitude],
        photo: hub_row[:photo],
        country: hub_row[:country],
        city: hub_row[:hub_name],
        geocoded_address: hub_row[:geocoded_address],
      )

      location = Location.find_or_create_by(
        name: hub_row[:hub_name],
        latitude: hub_row[:latitude],
        longitude: hub_row[:longitude],
        country: hub_row[:country],
        city: hub_row[:hub_name],
        geocoded_address: hub_row[:geocoded_address],
      )
      hub_code = hub_row[:hub_code] unless hub_row[:hub_code].blank?

      hub = Hub.find_by(
        nexus_id: nexus.id,
        tenant_id: user.tenant_id,
        hub_type: hub_row[:hub_type],
        name: "#{nexus.name} #{hub_type_name[hub_row[:hub_type]]}",
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
          photo: hub_row[:photo],
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
          photo: hub_row[:photo],
        )
        results[:hubs] << hub
        stats[:hubs][:number_created] += 1
      end

      results[:nexuses] << nexus
      stats[:nexuses][:number_updated] += 1

      hub.generate_hub_code!(user.tenant_id) unless hub.hub_code
      hub
    end

    {stats: stats, results: results}
  end

  def load_hub_images(params)
    xlsx = Roo::Spreadsheet.open(params["xlsx"])
    first_sheet = xlsx.sheet(xlsx.sheets.first)

    hub_rows = first_sheet.parse(hub_name: "NAME", url: "URL")

    hub_rows.each do |hub_row|
      imgstr = reduce_and_upload(hub_row[:hub_name], hub_row[:url])
      nexus = Location.find_by_name(hub_row[:hub_name])
      nexus.update_attributes(photo: imgstr[:sm])
      nexus.save!
    end
  end

  def overwrite_freight_rates(params, user = current_user, generate = false)
    mongo = get_client
    stats = {
      type: "pricings",
      pricings: {
        number_updated: 0,
        number_created: 0,
      },
      itineraryPricings: {
        number_updated: 0,
        number_created: 0,
      },
      itineraries: {
        number_updated: 0,
        number_created: 0,
      },
      stops: {
        number_updated: 0,
        number_created: 0,
      },
      layovers: {
        number_updated: 0,
        number_created: 0,
      },
      trips: {
        number_updated: 0,
        number_created: 0,
      },
      userPricings: {
        number_updated: 0,
        number_created: 0,
      },
      userAffected: [],
    }

    results = {
      pricings: [],
      itineraryPricings: [],
      userPricings: [],
      itineraries: [],
      stops: [],
      layovers: [],
      trips: [],
    }

    xlsx = Roo::Spreadsheet.open(params["xlsx"])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    pricing_rows = first_sheet.parse(
      customer_id: "CUSTOMER_ID",
      mot: "MOT",
      cargo_type: "CARGO_TYPE",
      effective_date: "EFFECTIVE_DATE",
      expiration_date: "EXPIRATION_DATE",
      origin: "ORIGIN",
      destination: "DESTINATION",
      vehicle: "VEHICLE",
      fee: "FEE",
      currency: "CURRENCY",
      rate_basis: "RATE_BASIS",
      rate_min: "RATE_MIN",
      rate: "RATE",
      hw_threshold: "HW_THRESHOLD",
      hw_rate_basis: "HW_RATE_BASIS",
      min_range: "MIN_RANGE",
      max_range: "MAX_RANGE",
      transit_time: "TRANSIT_TIME",
      carrier: "CARRIER",
      nested: "NESTED",
      wm_rate: "WM_RATE",
    )

    tenant = user.tenant
    aux_data = {}
    new_pricings = {}
    nested_pricings = {}
    new_itinerary_pricings = {}
    pricings_to_write = []
    user_pricings_to_write = []
    itinerary_pricings_to_write = []

    pricing_rows.each do |row|
      pricing_key = "#{row[:origin].gsub(/\s+/, "").gsub(/,+/, "")}_#{row[:destination].gsub(/\s+/, "").gsub(/,+/, "")}_#{row[:mot]}"
      new_pricings[pricing_key] = {} unless new_pricings[pricing_key]

      aux_data[pricing_key][:customer] = row[:customer_id] if row[:customer_id]

      effective_date = DateTime.parse(row[:effective_date].to_s)
      expiration_date = DateTime.parse(row[:expiration_date].to_s)
      cargo_type = row[:cargo_type]

      unless new_pricings[pricing_key][cargo_type]
        new_pricings[pricing_key][cargo_type] = {
          data: {},
          exceptions: [],
          effective_date: effective_date,
          expiration_date: expiration_date,
          updated_at: DateTime.now,
        }
      end
      if !aux_data[pricing_key]
        aux_data[pricing_key] = {}
      end
      if !aux_data[pricing_key][:vehicle]
        vehicle = TenantVehicle.find_by(name: row[:vehicle], mode_of_transport: row[:mot])
        if  vehicle
          aux_data[pricing_key][:vehicle] = vehicle
        else
          aux_data[pricing_key][:vehicle] = Vehicle.create_from_name( row[:vehicle], row[:mot], tenant.id)
        end
      end

      unless aux_data[pricing_key][:transit_time]
        aux_data[pricing_key][:transit_time] = row[:transit_time]
      end

      unless aux_data[pricing_key][:origin]
        aux_data[pricing_key][:origin] = Location.find_by(name: row[:origin], location_type: "nexus")
      end

      unless aux_data[pricing_key][:destination]
        aux_data[pricing_key][:destination] = Location.find_by(name: row[:destination], location_type: "nexus")
      end

      unless aux_data[pricing_key][:origin_hub_ids]
        aux_data[pricing_key][:origin_hub_ids] = aux_data[pricing_key][:origin].hubs_by_type(row[:mot], user.tenant_id).ids
      end

      unless aux_data[pricing_key][:destination_hub_ids]
        aux_data[pricing_key][:destination_hub_ids] = aux_data[pricing_key][:destination].hubs_by_type(row[:mot], user.tenant_id).ids
      end

      aux_data[pricing_key][:hub_ids] = aux_data[pricing_key][:origin_hub_ids] + aux_data[pricing_key][:destination_hub_ids]
      itinerary_name = "#{aux_data[pricing_key][:origin].name} - #{aux_data[pricing_key][:destination].name}"

      unless aux_data[pricing_key][:itinerary]
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
        results[:layovers] = generator_results[:results][:layovers]
        results[:trips] = generator_results[:results][:trips]
        stats[:layovers][:number_created] = generator_results[:results][:layovers].length
        stats[:trips][:number_created] = generator_results[:results][:trips].length
      end

      if row[:nested] && row[:nested] != ""
        nested_key = "#{effective_date.to_i}_#{aux_data[pricing_key][:itinerary].id}"
        unless nested_pricings[pricing_key]
          nested_pricings[pricing_key] = {cargo_type.to_s => {}}
        end

        unless nested_pricings[pricing_key][cargo_type][nested_key]
          nested_pricings[pricing_key][cargo_type][nested_key] = {
            data: {},
            effective_date: effective_date,
            expiration_date: expiration_date,
          }
        end

        unless nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]]
          nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]] = {
            rate: row[:rate],
            rate_basis: row[:rate_basis],
            currency: row[:currency],
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

          unless nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:range]
            nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:range] = []
          end

          nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:range] << {
            min: row[:min_range],
            max: row[:max_range],
            rate: row[:rate],
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
          new_pricings[pricing_key][cargo_type][:data][row[:fee]].delete("rate")
          unless new_pricings[pricing_key][cargo_type][:data][row[:fee]][:range]
            new_pricings[pricing_key][cargo_type][:data][row[:fee]][:range] = []
          end

          new_pricings[pricing_key][cargo_type][:data][row[:fee]][:range] << {
            min: row[:min_range],
            max: row[:max_range],
            rate: row[:rate],
          }
        end

        if row[:rate_min]
          new_pricings[pricing_key][cargo_type][:data][row[:fee]][:min] = row[:rate_min]
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
    
    new_pricings.each do |itKey, cargo_pricings|
      cargo_pricings.each do |cargo_key, pricing|
        
        transport_category = aux_data[itKey][:vehicle].vehicle.transport_categories.find_by(
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
        update_one: {
          filter: {
            _id: key,
          },
          update: {
            "$set" => value,
          }, upsert: true,
        },
      }
    end

    mongo["itineraryPricings"].bulk_write(itinerary_pricings_to_write)
    mongo["pricings"].bulk_write(pricings_to_write)
    mongo["userPricings"].bulk_write(user_pricings_to_write)

    sleep(5)

    tenant.update_route_details

    {results: results, stats: stats}
  end

  def price_split(basis, string)
    vals = string.split(" ")
    {
      "currency" => vals[1],
      "rate" => vals[0].to_i,
      "rate_basis" => basis,
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

    if load_type === "fcl"
      %w[fcl_20 fcl_40 fcl_40hq].each do |lt|
        p test
        p all_charges[lt]
        p all_charges[lt][direction]
        p charge
        p test
        all_charges[lt][direction][charge[:key]] = charge
      end
    else
      all_charges[load_type][direction][charge[:key]] = charge
    end

    all_charges
  end
end
