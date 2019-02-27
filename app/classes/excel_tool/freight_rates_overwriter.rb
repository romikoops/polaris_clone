# frozen_string_literal: true

module ExcelTool
  class FreightRatesOverwriter < ExcelTool::BaseTool
    attr_reader :first_sheet, :tenant, :aux_data, :new_pricings, :nested_pricings, :user, :effective_date,
                :expiration_date, :pricing_key, :cargo_type, :itinerary, :generate

    def post_initialize(args)
      @first_sheet = xlsx.sheet(xlsx.sheets.first)
      @user = args[:_user]
      @tenant = user.tenant
      @aux_data = {}
      @new_pricings = {}
      @nested_pricings = {}
      @generate = args[:generate]
    end

    def perform
      overwrite_freight_rates
    end

    private

    def overwrite_freight_rates
      @unsaved_itins = []
      @saved = []
      pricing_rows.each do |row|
        set_pricing_key(row)
        new_pricings[pricing_key] = {} unless new_pricings[pricing_key]
        set_dates(row)
        set_cargo_type(row)
        populate_new_pricings
        aux_data[pricing_key] ||= {}

        populate_aux_data(row)
        @itinerary = aux_data[pricing_key][:itinerary]
        update_aux_data_itinerary(row)
        save_stops
        populate_stats_and_results
        process_row_data(row)
      end
      add_exceptions_to_new_pricings
      process_hashes
      generate_map_data
      { results: results, stats: stats, unsaved_initnerary: @unsaved_itins, saved: @saved }
    end

    def save_stops
      aux_data[pricing_key][:stops_in_order] = map_stop_hubs
      itinerary.stops << aux_data[pricing_key][:stops_in_order]
      if itinerary.save
        @saved << itinerary
      else
        @unsaved_itins << @itinerary
      end
    end

    def generate_map_data
      @saved.each(&:generate_map_data)
    end

    def _stats
      {
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
    end

    def _results
      {
        pricings: [],
        itineraryPricings: [],
        userPricings: [],
        itineraries: [],
        stops: [],
        layovers: [],
        trips: []
      }
    end

    def pricing_rows
      rows = first_sheet.parse(
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
      rows.each do |row|
        row[:cargo_type].strip!
        row[:origin].strip!
        row[:destination].strip!
      end
    end

    def set_dates(row)
      @effective_date = DateTime.parse(row[:effective_date].to_s)
      @expiration_date = DateTime.parse(row[:expiration_date].to_s)
    end

    def set_pricing_key(row)
      @pricing_key = "#{row[:origin].gsub(/\s+/, '').gsub(/,+/, '')}\
      _#{row[:destination].gsub(/\s+/, '').gsub(/,+/, '')}\
      _#{row[:mot]}_#{row[:vehicle]}_#{row[:carrier]}_#{row[:customer_id]}_#{row[:effective_date]}"
    end

    def set_cargo_type(row)
      @cargo_type = row[:cargo_type] == 'cargo_item' ? 'lcl' : row[:cargo_type]
    end

    def populate_new_pricings
      new_pricings[pricing_key][cargo_type] ||= {
        data: {},
        exceptions: [],
        effective_date: effective_date,
        expiration_date: expiration_date,
        updated_at: DateTime.now
      }
    end

    def find_nexus(string, tenant_id)
      nexus = Nexus.find_by(name: string, tenant_id: tenant_id)
      nexus || Nexus.where('name ILIKE ? AND tenant_id = ?', "%#{string}%", tenant_id).first
    end

    def tenant_vehicle(row)
      if row[:carrier]
        carrier = Carrier.find_or_create_by!(name: row[:carrier])
        carrier.tenant_vehicles.find_by(
          tenant_id: user.tenant_id,
          mode_of_transport: row[:mot].downcase,
          name: row[:vehicle]
        )
      else
        TenantVehicle.find_by(
          tenant_id: user.tenant_id,
          mode_of_transport: row[:mot].downcase,
          name: row[:service_level]
        )
      end
    end

    def populate_aux_data(row)
      if aux_data[pricing_key][:tenant_vehicle].blank?
        vehicle = tenant_vehicle(row)

        aux_data[pricing_key][:tenant_vehicle] = vehicle.presence ||
                                                 Vehicle.create_from_name(row[:vehicle], row[:mot], tenant.id, row[:carrier])
      end
      aux_data[pricing_key][:load_type] = row[:cargo_type] == 'lcl' ? 'cargo_item' : 'container'
      aux_data[pricing_key][:customer] = User.find_by(email: row[:customer_id], tenant_id: user.tenant_id) if row[:customer_id]
      aux_data[pricing_key][:transit_time] ||= row[:transit_time]
      aux_data[pricing_key][:origin] ||= find_nexus(row[:origin], user.tenant_id)
      aux_data[pricing_key][:destination] ||= find_nexus(row[:destination], user.tenant_id)
      aux_data[pricing_key][:origin_hub_ids] ||= aux_data[pricing_key][:origin].hubs_by_type(row[:mot], user.tenant_id).ids
      aux_data[pricing_key][:destination_hub_ids] ||= aux_data[pricing_key][:destination].hubs_by_type(row[:mot], user.tenant_id).ids

      aux_data[pricing_key][:hub_ids] = aux_data[pricing_key][:origin_hub_ids] + aux_data[pricing_key][:destination_hub_ids]
    end

    def update_aux_data_itinerary(row)
      if itinerary.blank?
        itinerary_name = "#{aux_data[pricing_key][:origin].name} - #{aux_data[pricing_key][:destination].name}"
        @itinerary = tenant.itineraries.find_by(mode_of_transport: row[:mot], name: itinerary_name)
        if itinerary.blank?
          @itinerary = tenant.itineraries.new(mode_of_transport: row[:mot], name: itinerary_name)
          stats[:itineraries][:number_created] += 1
        else
          stats[:itineraries][:number_updated] += 1
        end
        aux_data[pricing_key][:itinerary] = itinerary
      end
    end

    def map_stop_hubs
      aux_data[pricing_key][:hub_ids].map.with_index do |h, i|
        stop = itinerary.stops.find_by(hub_id: h, index: i)
        if stop.nil?
          stop = Stop.new(hub_id: h, index: i)
          stats[:stops][:number_created] += 1
        else
          stats[:stops][:number_updated] += 1
        end
        results[:stops] << stop
        stop
      end
    end

    def steps_in_order
      _steps_in_order = []
      (aux_data[pricing_key][:stops_in_order].length - 1).times do
        _steps_in_order << aux_data[pricing_key][:transit_time].to_i
      end
      _steps_in_order
    end

    def populate_stats_and_results
      start_date = DateTime.now
      end_date = generate ? start_date + 60.days : start_date + 5.days
      unless @unsaved_itins.include?(@itinerary)
        generator_results = aux_data[pricing_key][:itinerary].generate_weekly_schedules(
          aux_data[pricing_key][:stops_in_order],
          steps_in_order,
          start_date,
          end_date,
          [1, 5],
          aux_data[pricing_key][:tenant_vehicle].id,
          aux_data[pricing_key][:load_type]
        )
        results[:layovers] = generator_results[:results][:layovers]
        results[:trips] = generator_results[:results][:trips]
        stats[:layovers][:number_created] = generator_results[:results][:layovers].length
        stats[:trips][:number_created] = generator_results[:results][:trips].length
      end
    end

    def nested_key
      "#{effective_date.to_i}_#{aux_data[pricing_key][:itinerary].id}"
    end

    def add_nested_key_values
      nested_pricings[pricing_key][cargo_type][nested_key] ||= {
        data: {},
        effective_date: effective_date,
        expiration_date: expiration_date
      }
    end

    def add_nested_key_values_with_rows(row)
      nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]] ||= {
        rate: row[:rate],
        rate_basis: row[:rate_basis],
        currency: row[:currency],
        min: row[:rate_min]
      }
    end

    def nested_min_range(row)
      if row[:min_range]
        nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]].delete('rate')
        nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:range] ||= []
        nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:range] << {
          min: row[:min_range],
          max: row[:max_range],
          rate: row[:rate]
        }
      end
    end

    def add_fee_to_new_princings(row)
      new_pricings[pricing_key][cargo_type][:data][row[:fee]] = {
        rate: row[:rate],
        rate_basis: row[:rate_basis],
        currency: row[:currency],
        min: row[:rate_min]
      }
    end

    def new_princings_min_range(row)
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

    def add_exceptions_to_new_pricings
      nested_pricings.each do |p_key, cargo_values|
        cargo_values.each do |c_key, nested_values|
          nested_values.each do |_n_key, value|
            new_pricings[p_key][c_key][:exceptions] << value
          end
        end
      end
    end

    def process_row_data(row)
      if row[:nested].present?
        nested_pricings[pricing_key] ||= { cargo_type.to_s => {} }
        add_nested_key_values
        add_nested_key_values_with_rows(row)
        if row[:hw_threshold]
          nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:hw_threshold] = row[:hw_threshold]
        end

        if row[:hw_rate_basis]
          nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:hw_rate_basis] = row[:hw_rate_basis]
        end

        nested_min_range(row)
        nested_pricings[pricing_key][cargo_type][nested_key][:data][row[:fee]][:min] = row[:rate_min] if row[:rate_min]
      else
        add_fee_to_new_princings(row) unless new_pricings[pricing_key][cargo_type][:data][row[:fee]]
        new_pricings[pricing_key][cargo_type][:wm_rate] = row[:wm_rate]

        if row[:hw_threshold]
          new_pricings[pricing_key][cargo_type][:data][row[:fee]][:hw_threshold] = row[:hw_threshold]
        end

        if row[:hw_rate_basis]
          new_pricings[pricing_key][cargo_type][:data][row[:fee]][:hw_rate_basis] = row[:hw_rate_basis]
        end
        new_princings_min_range(row)
      end
    end

    def process_hashes
      new_pricings.each do |it_key, cargo_pricings|
        cargo_pricings.each do |cargo_key, pricing_data|
          new_pricing_data = pricing_data.clone
          transport_category = aux_data[it_key][:tenant_vehicle].vehicle.transport_categories.find_by(name: 'any', cargo_class: cargo_key)
          itinerary = aux_data[it_key][:itinerary]
          user = aux_data[it_key][:customer]

          next unless itinerary.id

          pricing = itinerary.pricings.find_or_create_by!(
            transport_category: transport_category,
            tenant: tenant,
            user: user,
            tenant_vehicle_id: aux_data[it_key][:tenant_vehicle].id,
            effective_date: pricing_data[:effective_date],
            expiration_date: pricing_data[:expiration_date]
          )
          pricing_details = new_pricing_data.delete(:data)
          pricing_exceptions = new_pricing_data.delete(:exceptions)
          pricing.update(new_pricing_data)
          pricing_details.each do |shipping_type, pricing_detail_data|
            ChargeCategory.from_code(shipping_type, @tenant.id)
            currency = pricing_detail_data.delete(:currency)
            pricing_detail_params = pricing_detail_data.merge(shipping_type: shipping_type, tenant: tenant)
            range = pricing_detail_params.delete(:range)
            pricing_detail = pricing.pricing_details.where(pricing_detail_params).first_or_create!(pricing_detail_params)
            pricing_detail.update!(range: range, currency_name: currency)
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
    end
  end
end
