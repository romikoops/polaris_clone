module ExcelTool
  class OverrideCityTruckingRatesByHub
    attr_reader :stats, :results, :xlsx, :courier, :hub, :direction, :_user, :hub_id, :load_type, :tenant
    
    def initialize(args = { _user: current_user })
      params = args[:params]
      @courier = args[:courier_name]
      @direction = find_or_create_courier(args[:direction])
      @stats = _stats
      @results = _results
      @defaults = []
      @xlsx = open_file(params["xlsx"])
      @load_type = "cargo_item"
      @tenant = args[:_user].tenant
      @hub_id = args[:hub_id]
      @hub = Hub.find(hub_id)
    end

    def perform
      p direction
      xlsx.sheets.each do |sheet_name|
        first_sheet = xlsx.sheet(sheet_name)
        weight_cat_row = first_sheet.row(2)
        num_rows = first_sheet.last_row
        update_defaults(weight_cat_row)
        update_sheet(first_sheet, row_data, nexus, trucking_table_id)
      end
      { stats: stats, results: results }
    end

    private

    def _stats
      {
        type: "trucking",
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
    end

    def _results
      {
        trucking_hubs: [],
        trucking_queries: [],
        trucking_pricings: []
      }
    end

    def find_or_create_courier(courier_name)
      Courier.find_or_create_by(name: courier_name, tenant: tenant)
    end

    def open_file(file)
      Roo::Spreadsheet.open(file)
    end

    def update_defaults(weight_cat_row)
      [3, 4, 5, 6].each do |i|
        min_max_arr = weight_cat_row[i].split(" - ")
        defaults.push(min_weight: min_max_arr[0].to_i, max_weight: min_max_arr[1].to_i, value: nil, min_value: nil)
      end
    end

    def init_client(row_data)
      {
        province: row_data[0].downcase,
        city:     row_data[1].downcase,
        dist_hub: row_data[2].split(" , ")
      }
    end

    def init_new_pricing(row_data, nexus, trucking_table_id)
      { city: init_client(row_data),
        currency: "CNY"
        tenant_id: tenant.id
        nexus_id: nexus.id
        trucking_hub_id: trucking_table_id
        delivery_eta_in_days: row_data[10]
        modifier: "kg"
        direction: direction
      }
    end

    def uuid
      SecureRandom.uuid
    end

    def trucking_destination(row_data)
      TruckingDestination.find_or_create_by!(city_name: trucking_city(row_data), country_code: "CN")
    end

    def trucking_city(row_data)
      Location.get_trucking_city("#{row_data[1]}, #{row_data[0]}")
    end

    def hub_trucking_by_destination(destination_id)
      HubTrucking.find_or_initialize_by(trucking_destination_id: destination_id, hub_id: hub.id)
    end

    def clone_tmp(row_data, new_pricing)
      tmp = defaults[i - 3].clone
      tmp[:delivery_eta_in_days] = row_data[10]
      ntp[:modifier] = "kg"
      tmp[:type] = "default"
      tmp[:cbm_ratio] = 250
      tmp[:fees] = {
        base_rate: {
          kg:         row_data[i],
          cbm:        row_data[7],
          rate_basis: "PER_CBM_KG",
          currency:   "CNY"
        },
        vat:       {
          value:      0.06,
          rate_basis: "PERCENTAGE",
          currency:   "CNY"
        }
      }
      if direction === "export"
        tmp[:fees][:PUF] = { value: row_data[8], currency: new_pricing[:currency], rate_basis: "PER_SHIPMENT" }
      else
        tmp[:fees][:DLF] = { value: row_data[9], currency: new_pricing[:currency], rate_basis: "PER_SHIPMENT" }
      end
      tmp
    end

    def update_ntp(ntp, row_data, new_pricing)
      ntp[:load_type] = load_type
      ntp[:tenant_id] = hub.tenant_id
      ntp[direction]["table"] << clone_tmp(row_data, new_pricing)
    end

    def populate_new_trucking_pricing(ntp, row_data, new_pricing)
      [3, 4, 5, 6].each do |i|
        ntp = update_ntp(ntp, row_data, new_pricing)
        stats[:trucking_pricings][:number_updated] += 1
      end
      ntp
    end

    def update_or_create_hub_trucking(td)
      hub_trucking = hub_trucking_by_destination(td.id)
      if hub_trucking.trucking_pricing_id
        trucking_pricing = TruckingPricing.find(hub_trucking.trucking_pricing_id)
        trucking_pricing.update_attributes(ntp)
      else
        trucking_pricing = courier.trucking_pricings.create!(ntp)
        hub_trucking.trucking_pricing_id = trucking_pricing.id
        hub_trucking.save!
      end
    end

    def update_sheet(first_sheet, row_data, nexus, trucking_table_id)
      (3..num_rows).each do |line|
        row_data = first_sheet.row(line)
        new_pricing = init_new_pricing(row_data, nexus, trucking_table_id)
        ntp = new_pricing
        ntp[:_id] = uuid
        td = trucking_destination(row_data)
        new_pricing[direction] = { "table" => [] }
        ntp = new_pricing
        ntp[:truck_type] = "default"
        ntp = populate_new_trucking_pricing(ntp, row_data, new_pricing)
        update_or_create_hub_trucking(td)
        stats[:trucking_queries][:number_updated] += 1
      end
    end
  end
end