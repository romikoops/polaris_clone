class OfferCalculator
  attr_reader :shipment, :total_price, :has_pre_carriage, :has_on_carriage, :schedules, :truck_seconds_pre_carriage, :origin_hubs, :destination_hubs, :itineraries, :itineraries_hash, :carriage_nexuses, :delay, :trucking_data
  include CurrencyTools
  include PricingTools
  include TruckingTools
  def initialize(shipment, params, user)
    @mongo            = get_client
    @user             = user
    @shipment         = shipment
    @origin_hubs      = []
    @destination_hubs = []
    @itineraries      = []
    @itineraries_hash = {}
    @carriage_nexuses = params[:shipment][:carriageNexuses]
    @shipment.has_pre_carriage = params[:shipment][:has_pre_carriage]
    @shipment.has_on_carriage  = params[:shipment][:has_on_carriage]
    @shipment.trucking = trucking_params(params).to_h
    @delay = params[:shipment][:delay]
    @shipment.incoterm_id = params[:shipment][:incoterm]
    @trucking_data = {}
    @truck_seconds_pre_carriage = 0
    @pricing = nil

    @current_eta_in_search = DateTime.new
    @total_price = { total:0, currency: "EUR" }

    if params[:shipment][:aggregated_cargo_attributes]
      @shipment.aggregated_cargo.try(:destroy)
      @shipment.aggregated_cargo = AggregatedCargo.new(aggregated_cargo_params(params))
      @cargo_units = [@shipment.aggregated_cargo]
    else    
      cargo_unit_const = @shipment.load_type.camelize.constantize
      plural_load_type = @shipment.load_type.pluralize
      @shipment.send(plural_load_type).destroy_all
      @cargo_units = cargo_unit_const.extract(send("#{plural_load_type}_params", params))
      @shipment.send("#{plural_load_type}=", @cargo_units)
    end


    @shipment.planned_pickup_date = Chronic.parse(
      params[:shipment][:planned_pickup_date], 
      endian_precedence: :little
    )
    @shipment.origin = Location.get_geocoded_location(
      params[:shipment][:origin_user_input],
      params[:shipment][:origin_id],
      shipment.has_pre_carriage
    )
    raise ApplicationError::NoOrigin unless @shipment.origin
    
    @shipment.destination = Location.get_geocoded_location(
      params[:shipment][:destination_user_input],
      params[:shipment][:destination_id],
      shipment.has_on_carriage
    )
    raise ApplicationError::NoDestination unless @shipment.destination
  end

  def calc_offer!
    determine_trucking_options!
    determine_itinerary!
    # determine_route! 
    determine_hubs!

    # TBD - Trucking
    # You have access to the following property in shipment:
    # @shipment.trucking #=> {
    #   "on_carriage"  => { "truck_type" => "chassis"},
    #   "pre_carriage" => { "truck_type" => "side_lifter"}
    # }
    determine_longest_trucking_time!
    determine_layovers!
    
    
    # determine_schedules!
    # add_schedules_charges!
    add_trip_charges! 
    convert_currencies!
    prep_schedules!
  end

  def calc_alternative_schedules!(up_to)
    begin
      up_to.times do
        @current_eta_in_search = @schedule_set_arr.last.set.first.eta + 1.second
        schedules = schedules_on_route
        @schedule_set_arr << ScheduleSet.new(schedules, @truck_seconds_pre_carriage, shipment.has_on_carriage)
      end
    rescue
      return
    end
  end

  private

  def determine_itinerary!
    data  = Itinerary.for_locations(@shipment, @trucking_data)
    @itineraries = data[:itineraries]
    @origin_hubs = data[:origin_hubs]
    @destination_hubs = data[:destination_hubs]
    
    raise ApplicationError::NoRoute unless @itineraries
  end

  def determine_hubs!
    @furthest_hub_from_origin    = @shipment.origin.furthest_hub(@origin_hubs)
    @furthest_hub_to_destination = @shipment.destination.furthest_hub(@destination_hubs)
  end

  def determine_longest_trucking_time!
    begin
      if shipment.has_pre_carriage
        google_directions = GoogleDirections.new(
          @shipment.origin.lat_lng_string,
          @furthest_hub_from_origin.lat_lng_string,
          @shipment.planned_pickup_date.to_i
        )
        
        driving_time = google_directions.driving_time_in_seconds
        @longest_trucking_time = google_directions.driving_time_in_seconds_for_trucks(driving_time)
      else
        @longest_trucking_time = 0
      end
      @current_eta_in_search = @shipment.planned_pickup_date + @longest_trucking_time.seconds + 3.days
    rescue
      raise ApplicationError::NoTruckingTime
    end
  end

  def determine_schedules!
    begin
      @schedules = @shipment.route.schedules.joins(:vehicle).joins(:transport_categories)
        .where("transport_categories.name = 'any'")
        .where("etd > ? AND etd < ?", @shipment.planned_pickup_date, @shipment.planned_pickup_date + 10.days).limit(20).order(:etd).uniq
    rescue
      raise ApplicationError::NoSchedules
    end
  end

  def determine_layovers!
    delay = @delay ? @delay.to_i : 20
    schedule_obj = {}
    @itineraries.each do |itin|
      
      destination_stop = itin.stops.where(hub_id: @destination_hubs).first
      origin_stop = itin.stops.where(hub_id: @origin_hubs).first
      origin_layovers = origin_stop.layovers.where("closing_date > ? AND closing_date < ?", @shipment.planned_pickup_date, @shipment.planned_pickup_date + delay.days).order(:etd).uniq
      trip_layovers = origin_layovers.each_with_object({}) do |ol, return_hash|
        return_hash[ol.trip_id] = [
          ol,
          Layover.find_by(trip_id: ol.trip_id, stop_id: destination_stop.id)
        ]
      end
      
      schedule_obj[itin.id] = trip_layovers unless trip_layovers.empty?
    end
    
    @itineraries_hash = schedule_obj
  end

  def add_trip_charges!
    charges = {}
    @total_price[:cargo] = { value: 0, currency: '' }
    
    @itineraries_hash.select! do |itinerary_id, trips|
      trip = trips.values.first
      
      if trip && trip.length > 1
        sched_key = "#{trip[0].stop.hub_id}-#{trip[1].stop.hub_id}"
        
        next if charges[sched_key]

        charges[sched_key] = { trucking_on: {}, trucking_pre: {}, import: {}, export: {}, cargo: {} }
        set_local_charges!(charges, trip, sched_key)
        set_trucking_charges!(charges, trip, sched_key)
        
        set_cargo_charges!(charges, trip, sched_key)
       
      end
    end
    
    charges.reject! { |_, charge| charge[:cargo].empty? }
    
    raise ApplicationError::NoSchedulesCharges if charges.empty?
    @shipment.schedules_charges = charges
  end

  def set_trucking_charges!(charges, trip, sched_key)
    if @shipment.has_pre_carriage
      charges[sched_key][:trucking_pre] = determine_trucking_fees(
        @shipment.origin,
        trip[0].stop.hub,
        'origin',
        'export'
      )
    end
    
    if @shipment.has_on_carriage
      charges[sched_key][:trucking_on] = determine_trucking_fees(
        @shipment.destination, 
        trip[1].stop.hub,
        'destination',
        'import'
      )
    end
  end

  def set_local_charges!(charges, trip, sched_key)
    if @shipment.has_pre_carriage
      charges[sched_key][:export] = determine_local_charges(
        trip[0].stop.hub,
        @shipment.load_type,
        @cargo_units,
        'export',
        trip[0].itinerary.mode_of_transport,
        @user
      )
      
    end
    
    if @shipment.has_on_carriage
      charges[sched_key][:import] = determine_local_charges(
        trip[1].stop.hub,
        @shipment.load_type,
        @cargo_units,
        'import',
        trip[1].itinerary.mode_of_transport,
        @user
      )
    end
  end

  def prep_schedules!
    schedules = []
    
    @itineraries_hash.each do |iKey, iValue|
      iValue.each do |tKey, tValue|
        if tValue.length > 1 && @shipment.schedules_charges["#{tValue[0].stop.hub_id}-#{tValue[1].stop.hub_id}"]
          schedules.push({
            id: SecureRandom.uuid,
            total: @shipment.schedules_charges["#{tValue[0].stop.hub_id}-#{tValue[1].stop.hub_id}"]["total"],
            itinerary_id: iKey,
            eta: tValue[1].eta, 
            etd: tValue[0].etd,
            closing_date: tValue[0].closing_date,
            mode_of_transport: tValue[0].itinerary.mode_of_transport, 
            hub_route_key: "#{tValue[0].stop.hub_id}-#{tValue[1].stop.hub_id}", 
            tenant_id: @shipment.tenant_id, 
            trip_id: tKey, 
            origin_layover_id: tValue[0].id,
            destination_layover_id: tValue[1].id})
        end
      end
    end
    @schedules = schedules
  end

  def set_cargo_charges!(charges, trip, sched_key)
    total_units = @cargo_units.reduce(0) { |sum, cargo_unit| sum += cargo_unit.try(:quantity).to_i }

    @cargo_units.each do |cargo_unit|
      path_key = path_key(cargo_unit, trip)
      
      charge_result = send("determine_#{@shipment.load_type}_price",
        cargo_unit, 
        path_key, 
        @user, 
        total_units,
        @shipment.planned_pickup_date
      )
      
      if charge_result
        charges[sched_key][:cargo][cargo_unit.id] = charge_result
      end
    end    
  end

  def path_key(cargo_unit, layovers)
    transport_category = layovers[0].trip.tenant_vehicle.vehicle.transport_categories.find_by(
      name: 'any',
      cargo_class: cargo_unit.try(:size_class) || 'lcl',
      mode_of_transport: layovers[0].trip.itinerary.mode_of_transport
    )
    "#{layovers[0].stop_id}_#{layovers.last.stop_id}_#{transport_category.id}"
  end

  def determine_trucking_options!
    load_type = @shipment.load_type 
    if @shipment.has_pre_carriage
      trucking_pricings_by_hub = TruckingPricing.find_by_filter(
        location: @shipment.origin, 
        load_type: load_type, 
        tenant_id: @user.tenant_id, 
        truck_type: @shipment.trucking["pre_carriage"]["truck_type"] != '' ? shipment.trucking["pre_carriage"]["truck_type"] : 'default',
        carriage: 'pre'
      )
      trucking_pricings_by_hub.each do |tp|
        if !@trucking_data["pre_carriage"]
          @trucking_data["pre_carriage"] = {}
        end
        @trucking_data["pre_carriage"][tp.hub_truckings.first.hub_id] = tp
      end
    end
    if @shipment.has_on_carriage
      trucking_pricings_by_hub = TruckingPricing.find_by_filter(
        location: @shipment.destination, 
        load_type: load_type, 
        tenant_id: @user.tenant_id, 
        truck_type: @shipment.trucking["on_carriage"]["truck_type"] != '' ? @shipment.trucking["on_carriage"]["truck_type"] : 'default',
        carriage: 'on'
      )
      
      trucking_pricings_by_hub.each do |tp|
        if !@trucking_data["on_carriage"]
          @trucking_data["on_carriage"] = {}
        end
        @trucking_data["on_carriage"][tp.hub_truckings.first.hub_id] = tp
      end
    end
  end
  
  def determine_trucking_fees(location, hub, target, direction)
    google_directions = GoogleDirections.new(location.lat_lng_string, hub.lat_lng_string, @shipment.planned_pickup_date.to_i)
    km = google_directions.distance_in_km
    carriage = direction == "import" ? "on_carriage" : "pre_carriage"
    trucking_pricing = @trucking_data[carriage][hub.id]
    price_results = calc_trucking_price(trucking_pricing, @cargo_units, km, direction)
  end
  
  def convert_currencies!
    @shipment.schedules_charges.each do |key, svalue|
      raw_totals = {}
      svalue["cargo"].each do |id, charges|
        if !raw_totals[charges["total"]["currency"]]
          raw_totals[charges["total"]["currency"]] = charges["total"]["value"].to_d
        else
          raw_totals[charges["total"]["currency"]] += charges["total"]["value"].to_d
        end
        
      end
      if !svalue["import"].empty?
        if !raw_totals[svalue["import"]["total"]["currency"]]
          raw_totals[svalue["import"]["total"]["currency"]] = svalue["import"]["total"]["value"].to_d
        else
          raw_totals[svalue["import"]["total"]["currency"]] += svalue["import"]["total"]["value"].to_d
        end
      end
      if !svalue["export"].empty?
        if !raw_totals[svalue["export"]["total"]["currency"]]
          raw_totals[svalue["export"]["total"]["currency"]] = svalue["export"]["total"]["value"].to_d
        else
          raw_totals[svalue["export"]["total"]["currency"]] += svalue["export"]["total"]["value"].to_d
        end
      end

      if svalue["trucking_on"] && svalue["trucking_on"]["total"]
        if !raw_totals[svalue["trucking_on"]["total"]["currency"]]
          raw_totals[svalue["trucking_on"]["total"]["currency"]] = svalue["trucking_on"]["total"]["value"].to_f
        else
          raw_totals[svalue["trucking_on"]["total"]["currency"]] += svalue["trucking_on"]["total"]["value"].to_f
        end
      end
      if svalue["trucking_pre"] && svalue["trucking_pre"]["total"]
        if !raw_totals[svalue["trucking_pre"]["total"]["currency"]]
          raw_totals[svalue["trucking_pre"]["total"]["currency"]] = svalue["trucking_pre"]["total"]["value"].to_f
        else
          raw_totals[svalue["trucking_pre"]["total"]["currency"]] += svalue["trucking_pre"]["total"]["value"].to_f
        end
      end

      converted_totals = sum_and_convert(raw_totals, @user.currency)
      @shipment.schedules_charges[key]["total"] = { value: converted_totals, currency: @user.currency }

      if @total_price[:total] == 0 
        @total_price[:total] = converted_totals
      elsif @total_price[:total] > converted_totals
        @total_price[:total] = converted_totals
      end
    end
    @shipment.total_price = { value: @total_price[:total], currency: @user.currency }
  end

  def schedules_on_route
    stop1 = Location.find(@shipment.route.origin_nexus_id)
    stop2 = Location.find(@shipment.route.destination_nexus_id)

    mode_of_transport = Route.get_mode_of_transport(stop1, stop2)
    Schedule.where(mode_of_transport: mode_of_transport, from: stop1.hub_name, to: stop2.hub_name)
      .where("eta > ?", @current_eta_in_search)
      .order(eta: :asc)
  end

  private

  def trucking_params(params)
    params.require(:shipment).require(:trucking).permit(
      on_carriage: :truck_type, pre_carriage: :truck_type
    )
  end

  def cargo_items_params(params)
    params.require(:shipment).permit(
      cargo_items_attributes: [
        :payload_in_kg, :dimension_x, :dimension_y, :dimension_z,
        :quantity, :cargo_item_type_id, :dangerous_goods, :stackable
      ]
    )[:cargo_items_attributes]
  end

  def containers_params(params)
    params.require(:shipment).permit(
      containers_attributes: [
        :payload_in_kg, :sizeClass, :tareWeight, :quantity, :dangerous_goods
      ]
    )[:containers_attributes].map do |container_attributes|
      container_attributes.to_h.deep_transform_keys { |k| k.to_s.underscore }
    end
  end

  def aggregated_cargo_params(params)
    params.require(:shipment).require(:aggregated_cargo_attributes).permit(:weight, :volume)
  end
end
