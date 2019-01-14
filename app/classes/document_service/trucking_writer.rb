# frozen_string_literal: true

module DocumentService
  class TruckingWriter
    include AwsConfig
    include WritingTool
    attr_reader :options, :tenant, :hub, :target_load_type, :filename, :directory, :header_values,
      :workbook, :unfiltered_results, :carriage_reducer, :results_by_truck_type, :dir_fees,
      :zone_sheet, :fees_sheet, :header_format, :pages, :zones, :identifier

    def initialize(options)
      @options = options
      @tenant = tenant_finder(options[:tenant_id])
      @hub = Hub.find(options[:hub_id])
      @target_load_type = options[:load_type]
      @filename = _filename
      @directory = "tmp/#{@filename}"
      @workbook = create_workbook(@directory)
      @unfiltered_results = TruckingPricing.find_by_hub_id(options[:hub_id])
      @carriage_reducer = {}
      @results_by_truck_type = {}
      @dir_fees = {}
      @header_format = @workbook.add_format
      @header_format.set_bold
      @zone_sheet = add_sheet("Zones")
      @fees_sheet = add_sheet("Fees")
      @pages = {}
      @zones = []
      @identifier = _identifier
    end

    def perform
      currency = ""
      truck_type = ""
      filtered_results.each do |ufr|
        meta = _meta(ufr)
        truck_type = meta[:truck_type]
        currency = meta[:currency]
        prepare_sheet_data(meta, ufr)
      end

      write_zone_to_sheet
      write_fees_to_sheet(truck_type, currency)
      write_rates_to_sheet
      workbook.close
      write_to_aws(directory, tenant, filename, "schedules_sheet")
    end

    private

    def filtered_results
      _results = unfiltered_results.select{ |ufr| ufr["truckingPricing"]["load_type"] == target_load_type }
      if identifier == 'distance'
        _results.sort_by! { |res| res[identifier][0][0].to_i }
      end
      _results
    end

    def prepare_sheet_data(meta, ufr)
      update_pages(meta, ufr)
      update_dir_fees(meta, ufr)
      update_zones(ufr)
    end

    def add_sheet(sheet_name)
      workbook.add_worksheet(sheet_name)
    end

    def _filename
       "#{hub.name}_#{target_load_type}_trucking_#{formated_date}.xlsx"
    end

    def _identifier
      ident = ""
      results = unfiltered_results.select{ |ufr| ufr["truckingPricing"]["load_type"] == target_load_type }
      if results.first["distance"]
        ident = 'distance'
      elsif results.first["zipcode"]
        ident = 'zipcode'
      elsif results.first["city"]
        ident = 'city'
      end
      ident
    end

    def _meta(ufr)
      {
        city: hub.nexus.name,
        currency: ufr["truckingPricing"]["rates"].first[1][0]["rate"]["currency"],
        load_meterage_ratio: ufr["truckingPricing"]["load_meterage"]["ratio"],
        load_meterage_limit: ufr["truckingPricing"]["load_meterage"]["height_limit"],
        cbm_ratio: ufr["truckingPricing"]["cbm_ratio"],
        scale: ufr["truckingPricing"]["modifier"],
        rate_basis: ufr["truckingPricing"]["rates"].first[1][0]["rate"]["rate_basis"],
        base: ufr["truckingPricing"]["rates"].first[1][0]["rate"]["base"] || 1,
        truck_type: ufr["truckingPricing"]["truck_type"],
        load_type: ufr["truckingPricing"]["load_type"],
        cargo_class: ufr["truckingPricing"]["cargo_class"],
        direction: ufr["truckingPricing"]["carriage"] == 'pre' ? "export": "import",
        courier: Courier.find(ufr["truckingPricing"]["courier_id"]).name
      }
    end

    def write_zone_to_sheet
      header_values = ["ZONE", identifier_to_write.upcase,  "RANGE", "COUNTRY_CODE"]
      header_values.each_with_index { |hv, i| zone_sheet.write(0, i, hv, header_format) }
      zone_row = 1
      zones.each_with_index do |zone_array, zone|
        zone_array[:idents].each do |zone_data|
          write_zone_data(zone_row, zone, zone_data, zone_array)
          zone_row += 1
        end
      end
    end

    def identifier_to_write
      if filtered_results.first["truckingPricing"]["identifier_modifier"]
        "#{identifier}_#{filtered_results.first["truckingPricing"]["identifier_modifier"]}"
      else
        identifier
      end
    end
    
    def write_zone_data(zone_row, zone, zone_data, zone_array)
      zone_sheet.write(zone_row, 0, zone)
      if zone_data[0] == zone_data[1]
        zone_sheet.write(zone_row, 1, zone_data[1])
        zone_sheet.write(zone_row, 3, zone_array[:country_code])
      else
        if identifier_to_write.include?("return")
          zone_1 = zone_data[0].to_f > 0 ? ((zone_data[0].to_f * 2) - 1).to_i : 0
          zone_sheet.write(zone_row, 2, "#{zone_1} - #{(zone_data[1].to_f * 2)}")
        else
          zone_sheet.write(zone_row, 2, "#{zone_data[0]} - #{zone_data[1]}")
        end
        zone_sheet.write(zone_row, 3, zone_array[:country_code])
      end
    end

    def fee_header_values
      %w(FEE MOT FEE_CODE TRUCK_TYPE DIRECTION CURRENCY RATE_BASIS TON CBM KG
      ITEM SHIPMENT BILL CONTAINER MINIMUM WM PERCENTAGE)
    end

    def update_pages(meta, ufr)
      page_key = "#{meta[:truck_type]}_#{meta[:cargo_class]}_#{meta[:load_type]}_#{meta[:direction]}"
      unless pages[page_key]
        pages[page_key] = {
          meta: meta,
          pricings: []
        }
      end
      unless pages[page_key][:pricings].include?(ufr)
        pages[page_key][:pricings].push(ufr)
      end
    end

    def update_dir_fees(meta, ufr)
      unless dir_fees[meta[:direction]]
        dir_fees[meta[:direction]] = ufr["truckingPricing"]["fees"]
      end
    end

    def update_zones(ufr)
      unless zones.include?({idents: ufr[identifier], country_code: ufr["countryCode"]})
        zones.push({idents: ufr[identifier], country_code: ufr["countryCode"]})
      end
    end

    def write_fees_to_sheet(truck_type, currency)
      row = 1
      fee_header_values.each_with_index { |hv, i| fees_sheet.write(0, i, hv, header_format) }
      dir_fees.deep_symbolize_keys!
      dir_fees.each do |carriage_dir, fees|
          fees.each do |key, fee|
            fees_sheet.write(row, 0, fee[:name])
            fees_sheet.write(row, 1, hub.hub_type)
            fees_sheet.write(row, 2, key)
            fees_sheet.write(row, 3, truck_type)
            fees_sheet.write(row, 4, carriage_dir)
            fees_sheet.write(row, 5, currency)
            fees_sheet.write(row, 6, fee[:rate_basis])
            case fee[:rate_basis]
            when "PER_CONTAINER"
              fees_sheet.write(row, 13, fee[:value])
            when "PER_ITEM"
              fees_sheet.write(row, 10, fee[:value])
            when "PER_BILL"
              fees_sheet.write(row, 12, fee[:value])
            when "PER_SHIPMENT"
              fees_sheet.write(row, 11, fee[:value])
            when "PER_CBM_TON"
              fees_sheet.write(row, 7, fee[:ton])
              fees_sheet.write(row, 8, fee[:cbm])
              fees_sheet.write(row, 14, fee[:min])
            when "PER_CBM_KG"
              fees_sheet.write(row, 9, fee[:kg])
              fees_sheet.write(row, 8, fee[:cbm])
              fees_sheet.write(row, 14, fee[:min])
            when "PER_WM"
              fees_sheet.write(row, 15, fee[:value])
            when "PERCENTAGE"
              fees_sheet.write(row, 16, fee[:value])
            end
            row += 1
          end
      end
    end

    def write_rates_to_sheet
      pages.values.each_with_index do |page, i|
        rates_sheet = workbook.add_worksheet(i.to_s)
        rates_sheet.write(3, 0, "ZONE")
        rates_sheet.write(3, 1, "MIN")
        rates_sheet.write(4, 0, "MIN")
        minimums = {}
        row = 5
        x = 2
        meta_x = 0
        page[:meta].each do |key, value|
          rates_sheet.write(0, meta_x, key.upcase)
          rates_sheet.write(1, meta_x, value)
          meta_x += 1
        end
        page[:pricings].first["truckingPricing"]["rates"].each do |key, rates_array|
          rates_array.each do |rate|
            next unless rate
            rates_sheet.write(2, x, key.downcase)
            rates_sheet.write(3, x, "#{rate["min_#{key}"]} - #{rate["max_#{key}"]}")
            x += 1
          end
        end
        page[:pricings].each_with_index do |result, i|
          rates_sheet.write(row, 0, i)
          rates_sheet.write(row, 1, result["truckingPricing"]["rates"].first[1][0]["min_value"])
          minimums[i] = result["truckingPricing"]["rates"].first[1][0]["min_value"]
          x = 2
          result["truckingPricing"]["rates"].each do |_key, rates_array|
            rates_array.each do |rate|
              next unless rate
              if rate["min_value"]
                rates_sheet.write(row, 1, rate["min_value"].round(2))
              else
                rates_sheet.write(row, 1, 0)
              end
              rates_sheet.write(row, x, rate["rate"]["value"].round(2))
              x += 1
            end
          end
          row += 1
        end
      end
    end
  end
end
