# frozen_string_literal: true

module DocumentService
  class TruckingWriter
    include AwsConfig
    include WritingTool
    attr_reader :options, :organization, :hub, :target_load_type, :directory, :header_values,
      :workbook, :trucking_pricings, :results_by_truck_type, :dir_fees,
      :zone_sheet, :fees_sheet, :header_format, :pages, :zones, :group

    def initialize(options)
      @options = options
      @organization = Organizations::Organization.find(options[:organization_id])
      @hub = Hub.find(options[:hub_id])
      @group = Groups::Group.find(options[:group_id])
      @target_load_type = options[:load_type]
      @directory = "tmp/#{filename}"
      @workbook = create_workbook(@directory)
      @trucking_pricings ||= Trucking::Trucking.where(
        hub_id: options[:hub_id],
        group_id: options[:group_id],
        organization_id: options[:organization_id],
        load_type: options[:load_type]
      ).current
      @results_by_truck_type = {}
      @dir_fees = {}
      @header_format = @workbook.add_format
      @header_format.set_bold
      @zone_sheet = add_sheet("Zones")
      @fees_sheet = add_sheet("Fees")
      @pages = {}
      @zones = Hash.new { |hash, key| hash[key] = [] }
    end

    def perform
      return if trucking_pricings.empty?

      write_zone_to_sheet
      write_fees_to_sheet
      write_rates_to_sheet
      workbook.close
      Rails.application.routes.url_helpers.rails_blob_url(legacy_file.file, disposition: "attachment")
    ensure
      workbook.close
    end

    def legacy_file
      @legacy_file ||= Legacy::File.create!(
        organization: organization,
        file: { io: File.open(directory), filename: filename, content_type: "application/vnd.ms-excel" },
        text: filename, doc_type: "trucking_sheet"
      )
    end

    def zone_frame
      @zone_frame ||= Rover::DataFrame.new(
        trucking_data.to_a.group_by { |trucking| trucking["rates"] }.each_with_index.flat_map do |(rate, grouped_truckings), index|
          zone_rows(grouped_truckings: grouped_truckings, index: index, rate: rate)
        end
      )
    end

    def zone_rows(grouped_truckings:, index:, rate:)
      secondary_string_and_countries(truckings: grouped_truckings).map do |secondary_string_and_country|
        {
          "rates" => rate,
          "zone" => index,
          "primary" => primary_string(truckings: grouped_truckings)
        }.merge(secondary_string_and_country)
      end
    end

    def direction_frame
      @direction_frame ||= Rover::DataFrame.new(
        [
          {
            "carriage" => "pre",
            "direction" => "export"
          },
          {
            "carriage" => "on",
            "direction" => "import"
          }
        ]
      )
    end

    def load_meterage_frame
      @load_meterage_frame ||= Rover::DataFrame.new(
        trucking_data.to_a.uniq { |trucking| trucking["load_meterage"] }.map do |trucking|
          load_meterage = JSON.parse(trucking["load_meterage"])
          trucking.slice("load_meterage", "carriage", "truck_type", "cargo_class", "load_type")
          .merge({
            "load_meterage_hard_limit" => load_meterage["hard_limit"] || "",
            "load_meterage_stackable_limit" => load_meterage["stackable_limit"] || "",
            "load_meterage_non_stackable_limit" => load_meterage["non_stackable_limit"] || "",
            "load_meterage_stackable_type" => load_meterage["stackable_type"] || "",
            "load_meterage_non_stackable_type" => load_meterage["non_stackable_type"] || "",
            "load_meterage_ratio" => load_meterage["ratio"] || ""
          })
        end
      )
    end

    def metadata_frame
      @metadata_frame ||= Rover::DataFrame.new(
        trucking_data[%w[truck_type cargo_class load_type carriage]].to_a.uniq.map do |uniq_row|
          build_meta(trucking:
            trucking_data[
              trucking_data["truck_type"] == uniq_row["truck_type"] &&
              trucking_data["cargo_class"] == uniq_row["cargo_class"] &&
              trucking_data["load_type"] == uniq_row["load_type"] &&
              trucking_data["carriage"] == uniq_row["carriage"]
            ].to_a.first)
        end
      ).left_join(load_meterage_frame, on: {
        "truck_type" => "truck_type",
        "cargo_class" => "cargo_class",
        "load_type" => "load_type",
        "carriage" => "carriage"
      }).left_join(direction_frame, on: { "carriage" => "carriage" })
    end

    def primary_string(truckings:)
      return "" if truckings.length > 1

      truckings.first["location_data"]
    end

    def secondary_string_and_countries(truckings:)
      return [{ "secondary" => "", "country_code" => truckings.first["country_code"] }] if truckings.length == 1

      consecutive_arrays(locations: truckings)
    end

    def trucking_data
      @trucking_data ||= Rover::DataFrame.new(
        trucking_pricings
        .joins(location: :country)
        .joins(tenant_vehicle: :carrier)
        .select("
          truck_type,
          cargo_class,
          load_type,
          carriage,
          COALESCE(load_meterage, '{}'::jsonb) as load_meterage,
          cbm_ratio,
          modifier as scale,
          carriers.name as carrier,
          tenant_vehicles.name as service,
          rates,
          fees,
          identifier_modifier,
          trucking_locations.id as location_id,
          trucking_locations.data as location_data,
          countries.code as country_code,
          LOWER(validity)::date as effective_date,
          UPPER(validity)::date as expiration_date
        ")
      )
    end

    def data_frame
      @data_frame ||= trucking_data
        .left_join(direction_frame, on: { "carriage" => "carriage" })
        .left_join(zone_frame, on: { "rates" => "rates" })
    end

    def add_sheet(sheet_name)
      workbook.add_worksheet(sheet_name)
    end

    def filename
      @filename ||= "#{hub.name}_#{target_load_type}_#{group.name}_trucking_#{formatted_date}.xlsx"
    end

    def build_meta(trucking:)
      rates = JSON.parse(trucking["rates"])
      rate = rates.dig(rates.keys.first, 0, "rate")
      {
        "city" => hub.nexus.name,
        "currency" => rate["currency"],
        "rate_basis" => rate["rate_basis"],
        "base" => rate["base"] || 1
      }.merge(trucking.slice(
        "load_meterage",
        "cbm_ratio",
        "truck_type",
        "load_type",
        "cargo_class",
        "direction",
        "carriage",
        "carrier",
        "service",
        "effective_date",
        "expiration_date",
        "scale"
      ))
    end

    def write_zone_to_sheet
      header_values = ["ZONE", *identifiers_to_write, "COUNTRY_CODE"]
      header_values.each_with_index { |header_value, index| zone_sheet.write(0, index, header_value, header_format) }
      zone_frame[%w[primary secondary country_code zone]].sort_by! { |r| r["zone"] }.to_a.each.with_index do |zone_row, index|
        write_zone_data(zone_row: zone_row, sheet_row: index + 1)
      end
    end

    def identifiers_to_write
      if identifier == "location" && [nil, "f"].exclude?(identifier_modifier)
        %w[POSTAL_CODE RANGE]
      elsif identifier == "location_id" && [nil, "f"].include?(identifier_modifier)
        %w[CITY PROVINCE]
      elsif identifier == "distance" && [nil, "f"].exclude?(identifier_modifier)
        ["#{identifier}_#{identifier_modifier}".upcase, "RANGE"]
      else
        [identifier.upcase, "RANGE"]
      end
    end

    def write_zone_data(zone_row:, sheet_row:)
      zone_sheet.write(sheet_row, 0, zone_row["zone"])
      zone_sheet.write(sheet_row, 1, zone_row["primary"])
      zone_sheet.write(sheet_row, 2, zone_row["secondary"])
      zone_sheet.write(sheet_row, 3, zone_row["country_code"])
    end

    def fee_header_values
      %w[FEE MOT FEE_CODE TRUCK_TYPE DIRECTION CURRENCY RATE_BASIS TON CBM KG
        ITEM SHIPMENT BILL CONTAINER MINIMUM WM PERCENTAGE]
    end

    def metadata_headers
      %w[
        city
        currency
        scale
        load_meterage_hard_limit
        load_meterage_stackable_limit
        load_meterage_non_stackable_limit
        load_meterage_stackable_type
        load_meterage_non_stackable_type
        load_meterage_ratio
        rate_basis
        base
        cbm_ratio
        truck_type
        load_type
        cargo_class
        direction
        carrier
        service
        effective_date
        expiration_date
      ]
    end

    def write_fees_to_sheet
      row = 1
      fee_header_values.each_with_index do |header_value, index|
        fees_sheet.write(0, index, header_value, header_format)
      end
      data_frame[%w[direction fees truck_type]].to_a.uniq.each do |fee_classification|
        JSON.parse(fee_classification["fees"]).each do |key, fee|
          fees_sheet.write(row, 0, fee["fee"] || fee["name"])
          fees_sheet.write(row, 1, hub.hub_type)
          fees_sheet.write(row, 2, key)
          fees_sheet.write(row, 3, fee_classification["truck_type"])
          fees_sheet.write(row, 4, fee_classification["direction"])
          fees_sheet.write(row, 5, fee["currency"])
          fees_sheet.write(row, 6, fee["rate_basis"])
          case fee["rate_basis"]
          when "PER_CONTAINER"
            fees_sheet.write(row, 13, fee["value"])
          when "PER_ITEM"
            fees_sheet.write(row, 10, fee["value"])
          when "PER_BILL"
            fees_sheet.write(row, 12, fee["value"])
          when "PER_SHIPMENT"
            fees_sheet.write(row, 11, fee["value"])
          when "PER_CBM_TON"
            fees_sheet.write(row, 7, fee["ton"])
            fees_sheet.write(row, 8, fee["cbm"])
            fees_sheet.write(row, 14, fee["min"])
          when "PER_CBM_KG"
            fees_sheet.write(row, 9, fee["kg"])
            fees_sheet.write(row, 8, fee["cbm"])
            fees_sheet.write(row, 14, fee["min"])
          when "PER_WM"
            fees_sheet.write(row, 15, fee["value"])
          when "PERCENTAGE"
            fees_sheet.write(row, 16, fee["percentage"])
          end
          row += 1
        end
      end
    end

    def write_rates_to_sheet
      data_frame[%w[truck_type cargo_class load_type carriage]].to_a.uniq.each_with_index do |page, index|
        rates_sheet = workbook.add_worksheet(index.to_s)
        rates_sheet.write(3, 0, "ZONE")
        rates_sheet.write(3, 1, "MIN")
        rates_sheet.write(4, 0, "MIN")
        minimums = {}
        rate_row = 5
        col = 2
        write_metadata(sheet: rates_sheet, page: page)
        filter_page_frame(page: page).each do |frame_row|
          frame_rates = JSON.parse(frame_row["rates"])
          frame_rates.each do |key, rates_array|
            rates_array.each do |rate|
              next unless rate

              rates_sheet.write(2, col, key.downcase)
              rates_sheet.write(3, col, "#{rate["min_#{key}"]} - #{rate["max_#{key}"]}")
              col += 1
            end
          end
          rates_sheet.write(rate_row, 0, frame_row["zone"])
          rates_sheet.write(rate_row, 1, frame_rates.first[1][0]["min_value"])
          minimums[frame_row["zone"]] = frame_rates.first[1][0]["min_value"]
          col = 2
          frame_rates.each_value do |rates_array|
            rates_array.each do |rate|
              next unless rate

              rates_sheet.write(rate_row, 1, rate["min_value"] ? rate["min_value"].round(2) : 0)
              rates_sheet.write(rate_row, col, rate.dig("rate", "value").round(2))
              col += 1
            end
          end
          rate_row += 1
        end
      end
    end

    def filter_page_frame(page:)
      data_frame[
        data_frame["truck_type"] == page["truck_type"] &&
          data_frame["cargo_class"] == page["cargo_class"] &&
          data_frame["load_type"] == page["load_type"] &&
          data_frame["carriage"] == page["carriage"]
      ].sort_by! { |row| row["zone"] }
        .to_a
        .uniq { |row| row["zone"] }
    end

    def write_metadata(sheet:, page:)
      metadata_row = metadata_frame[
        metadata_frame["truck_type"] == page["truck_type"] &&
          metadata_frame["cargo_class"] == page["cargo_class"] &&
          metadata_frame["load_type"] == page["load_type"] &&
          metadata_frame["carriage"] == page["carriage"]
      ].to_a.first
      metadata_headers.each_with_index do |key, metadata_index|
        sheet.write(0, metadata_index, key.upcase)
        sheet.write(1, metadata_index, metadata_row[key])
      end
    end

    def consecutive_arrays(locations:)
      alpha_groups = locations.group_by do |location|
        { alpha: location["location_data"].tr("^A-Z", ""), country: location["country_code"] }
      end
      alpha_groups.flat_map do |alpha_and_country, array|
        numeric = array.all? { |location| location["location_data"].tr("^0-9", "").present? }
        next locations if alpha_and_country[:alpha].present? && numeric.blank?

        num_array = array.map do |location|
          {
            data: location["location_data"].gsub(alpha_and_country[:alpha], ""),
            country_code: location["country_code"]
          }
        end
        secondary = [
          "#{alpha_and_country[:alpha]}#{num_array.first[:data]}",
          "#{alpha_and_country[:alpha]}#{num_array.last[:data]}"
        ].uniq.join(" - ")
        { "secondary" => secondary, "country_code" => alpha_and_country[:country] }
      end
    end

    private

    def identifier
      @identifier ||= Trucking::Location.find(trucking_data["location_id"].to_a.first).query
    end

    def identifier_modifier
      @identifier_modifier ||= (trucking_data["identifier_modifier"].to_a.first unless trucking_data["identifier_modifier"].to_a.first == "f")
    end
  end
end
