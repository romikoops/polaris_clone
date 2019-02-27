# frozen_string_literal: true

require 'fileutils'

module DataValidator
  class SampleSheets < DataValidator::BaseValidator
    attr_reader :tenants, :n_sample_itineraries

    TRUCKING_ADDRESSES_PER_COUNTRY = {
      'DE' => 'Afrikastraße 1, 20457 Hamburg, Germany',
      'GB' => '1 Oxford St, Soho, London W1D 2DF, UK',
      'CN' => '88 Henan Middle Rd, Huangpu Qu, Shanghai Shi, China, 200002',
      'SE' => 'Torgny Segerstedtsgatan 80, 426 77 Västra Frölunda, Sweden'
    }.freeze

    LCL_EXAMPLES = [{
      '#1-payload_in_kg' => 1000,
      '#1-dimension_x' => 120,
      '#1-dimension_y' => 80,
      '#1-dimension_z' => 160,
      '#1-stackable' => 1,
      '#1-quantity' => 6,
      '#1-dangerous_goods' => false
    }].freeze

    FCL_EXAMPLES = [{
      '#1-payload_in_kg' => 1000,
      '#1-size_class' => nil,
      '#1-quantity' => 1,
      '#1-dangerous_goods' => false
    }].freeze

    def initialize(options = {})
      @tenants = options[:tenants] || Tenant.all
      @n_sample_itineraries = options[:n_sample_itineraries]
    end

    def perform
      tenants.each do |tenant|
        file_path = Rails.root.join('tmp', 'sample_sheets', "#{tenant.subdomain}__sample_sheet.xlsx")
        FileUtils.mkdir_p(File.dirname(file_path))
        xlsx = WriteXLSX.new(file_path, tempdir: Rails.root.join('tmp', 'write_xlsx/').to_s)

        itineraries(tenant).each do |itinerary|
          itin_name = itinerary.name
          mot = itinerary.mode_of_transport
          start_hub = Hub.find(itinerary.origin_hub_ids.first)
          end_hub = Hub.find(itinerary.destination_hub_ids.first)

          itinerary.pricings.each_with_index do |pricing, pr_i|
            sheet_name = "#{pr_i + 1} - #{pricing.load_type} - #{itin_name}".delete(' ')[0..30]
            worksheet = xlsx.add_worksheet(sheet_name)
            setup_worksheet(worksheet, itinerary.pricings.length + 1)

            results =
              case pricing.cargo_class.downcase
              when 'lcl'
                build_lcl_data(itin_name, mot, pricing, start_hub, end_hub)
              when /fcl.+/
                build_fcl_data(itin_name, mot, pricing, start_hub, end_hub)
              end

            results.uniq! { |result| result.except('DATE') }

            horizontal_headers = results.first.keys
            worksheet.write_col(0, 0, horizontal_headers, header_format(xlsx))
            results.map(&:values).each_with_index do |data, col_i|
              worksheet.write_col(0, col_i + 1, data)
            end
          end
        end

        xlsx.close
      end
    end

    private

    def setup_worksheet(worksheet, col_count)
      worksheet.set_column(0, col_count - 1, 30) # set all columns to width 30
      worksheet.freeze_panes(0, 1) # freeze first column
    end

    def header_format(xlsx)
      return @header_format if @header_format

      @header_format = xlsx.add_format
      @header_format.set_bold
      @header_format
    end

    def hub_has_trucking(hub, load_type, carriage)
      hub.truck_type_availabilities.where(load_type: load_type, carriage: carriage).distinct.present?
    end

    def trucking_permutations
      @trucking_permutations ||= [true, false].repeated_permutation(2)
    end

    def trucking_address(hub)
      TRUCKING_ADDRESSES_PER_COUNTRY[hub.address.country.code]
    end

    def build_lcl_data(itin_name, mot, pricing, start_hub, end_hub)
      start_hub_has_trucking = hub_has_trucking(start_hub, 'cargo_item', 'pre')
      end_hub_has_trucking = hub_has_trucking(end_hub, 'cargo_item', 'on')
      pre_carriage_address = trucking_address(start_hub) if start_hub_has_trucking
      on_carriage_address = trucking_address(end_hub) if end_hub_has_trucking

      LCL_EXAMPLES.flat_map do |cargo_data|
        trucking_permutations.map do |should_do_truckings|
          part_1 =
            { 'ITINERARY' => itin_name,
              'MOT' => mot,
              'LOAD_TYPE' => pricing.load_type,
              'ORIGIN_TRUCK_TYPE' => 'default',
              'DESTINATION_TRUCK_TYPE' => 'default',
              'UNITS' => nil }.merge(cargo_data)

          part_2 =
            { 'PICKUP_ADDRESS' => should_do_truckings[0] ? pre_carriage_address : nil,
              'DELIVERY_ADDRESS' => should_do_truckings[1] ? on_carriage_address : nil,
              'CARRIER' => pricing.carrier,
              'SERVICE_LEVEL' => pricing.tenant_vehicle.name,
              'FREIGHT' => nil }.merge(freight_key_hashes(pricing.pricing_details))

          part_3 =
            { 'PRECARRIAGE' => nil,
              'ONCARRIAGE' => nil,
              'IMPORT' => nil }.merge(local_charge_key_hashes('import', 'lcl', mot, pricing.tenant_vehicle, end_hub, start_hub))

          part_4 =
            { 'EXPORT' => nil }.merge(local_charge_key_hashes('export', 'lcl', mot, pricing.tenant_vehicle, start_hub, end_hub))

          part_5 =
            { 'DATE' => DateTime.now + 7.days,
              'TOTAL' => nil }

          [part_1,
           part_2,
           part_3,
           part_4,
           part_5].inject(:merge)
        end
      end
    end

    def build_fcl_data(itin_name, mot, pricing, start_hub, end_hub)
      start_hub_has_trucking = hub_has_trucking(start_hub, 'container', 'pre')
      end_hub_has_trucking = hub_has_trucking(end_hub, 'container', 'on')
      pre_carriage_address = trucking_address(start_hub) if start_hub_has_trucking
      on_carriage_address = trucking_address(end_hub) if end_hub_has_trucking

      FCL_EXAMPLES.flat_map do |cargo_data|
        trucking_permutations.map do |should_do_truckings|
          part_1 =
            { 'ITINERARY' => itin_name,
              'MOT' => mot,
              'LOAD_TYPE' => pricing.load_type,
              'ORIGIN_TRUCK_TYPE' => 'chassis',
              'DESTINATION_TRUCK_TYPE' => 'chassis',
              'UNITS' => nil }.merge(cargo_data.merge('#1-size_class' => pricing.cargo_class))

          part_2 =
            { 'PICKUP_ADDRESS' => should_do_truckings[0] ? pre_carriage_address : nil,
              'DELIVERY_ADDRESS' => should_do_truckings[1] ? on_carriage_address : nil,
              'CARRIER' => pricing.carrier,
              'SERVICE_LEVEL' => pricing.tenant_vehicle.name,
              'FREIGHT' => nil }.merge(freight_key_hashes(pricing.pricing_details))

          part_3 =
            { 'PRECARRIAGE' => nil,
              'ONCARRIAGE' => nil,
              'IMPORT' => nil }.merge(local_charge_key_hashes('import', 'lcl', mot, pricing.tenant_vehicle, end_hub, start_hub))

          part_4 =
            { 'EXPORT' => nil }.merge(local_charge_key_hashes('export', 'lcl', mot, pricing.tenant_vehicle, start_hub, end_hub))

          part_5 =
            { 'DATE' => DateTime.now + 7.days,
              'TOTAL' => nil }

          [part_1,
           part_2,
           part_3,
           part_4,
           part_5].inject(:merge)
        end
      end
    end

    def itineraries(tenant)
      n_sample_itineraries ? tenant.itineraries.sample(n_sample_itineraries) : tenant.itineraries
    end

    def local_charge(direction, load_type, mot, tenant_vehicle, start_hub, end_hub)
      search_attrs = { direction: direction, load_type: load_type, mode_of_transport: mot, tenant_vehicle_id: tenant_vehicle.id }
      local_charge = start_hub.local_charges.find_by(**search_attrs, counterpart_hub_id: end_hub.id)
      local_charge ||= start_hub.local_charges.find_by(**search_attrs, counterpart_hub_id: nil)

      local_charge || {}
    end

    def local_charge_key_hashes(direction, load_type, mot, tenant_vehicle, start_hub, end_hub)
      local_charge = local_charge(direction, load_type, mot, tenant_vehicle, start_hub, end_hub)

      local_charge[:fees]&.keys&.uniq&.map { |key| { "-#{key}" => nil } }&.inject(:merge) || {}
    end

    def freight_key_hashes(pricing_details)
      pricing_details.map { |pricing_detail| { "-#{pricing_detail.shipping_type}" => nil } }&.inject(:merge) || {}
    end
  end
end
