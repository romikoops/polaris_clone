# frozen_string_literal: true

module DocumentService
  class PricingWriter
    include AwsConfig
    include WritingTool
    attr_reader :options, :filename, :tenant, :pricings, :aux_data, :dir, :workbook, :worksheet

    def initialize(options)
      @options         = options
      @filename        = filename_formatter(options)
      @tenant          = tenant_finder(options[:tenant_id])
      @pricings        = pricings_getter(@tenant.id)
      @aux_data        = default_aux_hash
      @dir             = "tmp/#{filename}"
      workbook_hash    = add_worksheet_to_workbook(create_workbook(@dir), pricing_sheet_header_text)
      @workbook        = workbook_hash[:workbook]
      @worksheet       = workbook_hash[:worksheet]
    end

    def perform
      row = 1
      pricings.each_with_index do |pricing, _i|
        pricing.deep_symbolize_keys!
        next if pricing[:expiration_date] < DateTime.now
        current_itinerary     = current_itinerary(pricing)
        origin_aux_data       = address_and_aux_data(pricing, 0, "id")
        current_origin        = origin_aux_data[:address]
        destination_aux_data  = address_and_aux_data(pricing, 1, "id")
        current_destination   = destination_aux_data[:address]
        carrier               = carrier(pricing)
        key_origin = aux_data[:itineraries][pricing[:itinerary_id]].dig("stops", 0, "id")
        key_destination = aux_data[:itineraries][pricing[:itinerary_id]].dig("stops", 1, "id")
        unless aux_data[:transit_times]["#{key_origin}_#{key_destination}"]
          layover = layover_hash(current_itinerary, pricing)
          destination_layover = layover[:destination_layover]
          origin_layover = layover[:origin_layover]
        end
        current_transit_time = aux_data[:transit_times]["#{key_origin}_#{key_destination}"]
        vehicle_hash = vehicle_aux_data(aux_data, pricing)
        current_vehicle = vehicle_hash[:current_vehicle]
        aux_data = vehicle_hash[:aux_data]

        pricing[:data].each do |key, fee|
          column = 2
          if fee[:range] && !fee[:range].empty?
            fee[:range].each do |range_fee|
              data = writeable_data(current_itinerary,
                pricing, current_origin,
                current_destination,
                current_transit_time,
                current_vehicle,
                key,
                fee,
                carrier,
                range_fee)
              data << range_fee[:min]
              data << range_fee[:max]
              @worksheet = write_to_sheet(worksheet, row, column, data)
              row += 1
            end
          else
            data = writeable_data(current_itinerary,
              pricing, current_origin,
              current_destination,
              current_transit_time,
              current_vehicle,
              key,
              fee,
              carrier)
            @worksheet = write_to_sheet(worksheet, row, column, data)
            row += 1
          end
        end

        next unless pricing[:exceptions] && !pricing[:exceptions].empty?
        pricing[:exceptions].each do |ex_pricing|
          ex_pricing[:data].each do |key, fee|
            data = ["TRUE", nil, current_itinerary.mode_of_transport, pricing[:load_type], ex_pricing[:effective_date], ex_pricing[:expiration_date], current_origin.name, current_destination.name, current_transit_time, pricing[:wm_rate], current_vehicle.name, key, fee[:currency], fee[:rate_basis], fee[:min], fee[:rate]]
            data << fee[:hw_threshold] || ""
            data << fee[:hw_rate_basis] || ""
            @worksheet = write_to_sheet(worksheet, row, 1, data)
            row += 1
          end
        end
      end
      workbook.close
      write_to_aws(dir, tenant, filename, "pricings_sheet")
    end

    private

    def current_itinerary(pricing)
      itinerary = itinerary(pricing[:itinerary_id])
      unless aux_data[:itineraries][pricing[:itinerary_id]]
        aux_data[:itineraries][pricing[:itinerary_id]] = itinerary.as_options_json
      end

      itinerary
    end

    def pricings_getter(tenant_id)
      if options[:mot]
        get_tenant_pricings_by_mot(tenant_id, options[:mot])
      else
        get_tenant_pricings(tenant_id)
      end
    end

    def vehicle_aux_data(aux_data, pricing)
      unless aux_data[:vehicle][pricing[:transport_category_id]]
        vehicle = transport_category(pricing[:transport_category_id]).vehicle
        aux_data[:vehicle][pricing[:transport_category_id]] = vehicle
      end
      {
        current_vehicle: aux_data[:vehicle][pricing[:transport_category_id]],
        aux_data:        aux_data
      }
    end

    def transport_category(transport_category_id)
      TransportCategory.find(transport_category_id)
    end

    def carrier(pricing)
      tenant_vehicle = TenantVehicle.find(pricing[:tenant_vehicle_id])
      tenant_vehicle.carrier ? tenant_vehicle.carrier.name : nil
    end

    def address_and_aux_data(pricing, key1, key2)
      stop_id = aux_data[:itineraries][pricing[:itinerary_id]].dig("stops", key1, key2)
      aux_data[:nexuses][stop_id] = stop(stop_id).hub.nexus unless aux_data[:nexuses][stop_id]
      { address: aux_data[:nexuses][stop_id], aux_data: aux_data }
    end

    def pricing_sheet_header_text
      %w(CUSTOMER_ID NESTED CARRIER MOT CARGO_TYPE
         EFFECTIVE_DATE EXPIRATION_DATE ORIGIN DESTINATION
         TRANSIT_TIME WM_RATE VEHICLE FEE CURRENCY RATE_BASIS
         RATE_MIN RATE HW_THRESHOLD HW_RATE_BASIS MIN_RANGE MAX_RANGE)
    end

    def layover_hash(current_itinerary, pricing)
      tmp_trip = current_itinerary.trips.last
      key_origin = aux_data[:itineraries][pricing[:itinerary_id]]["stops"][0]["id"]
      key_destination = aux_data[:itineraries][pricing[:itinerary_id]]["stops"][1]["id"]
      if tmp_trip
        destination_layover = nil
        origin_layover = nil
        tmp_layovers = current_itinerary.trips.last.layovers
        tmp_layovers.each do |lay|
          origin_layover = lay if lay.stop_id == key_origin.to_i
          destination_layover = lay if lay.stop_id == key_destination.to_i
        end
        diff = ((tmp_trip.end_date - tmp_trip.start_date) / 86_400).to_i
        aux_data[:transit_times]["#{key_origin}_#{key_destination}"] = diff
      else
        aux_data[:transit_times]["#{key_origin}_#{key_destination}"] = ""
      end

      {
        destination_layover: destination_layover,
        origin_layover:      origin_layover,
        aux_data:            aux_data
      }
    end

    def get_tenant_pricings_by_mot(tenant_id, mot)
      itinerary_ids = Tenant.find(tenant_id).itineraries.where(mode_of_transport: mot).ids
      Pricing.where(itinerary_id: itinerary_ids).map(&:as_json)
    end

    def get_tenant_pricings(tenant_id)
      Pricing.where(tenant_id: tenant_id).map(&:as_json)
    end

    def map_itin_pricings(itin)
      itin.pricings.map(&:as_json)
    end
  end
end
