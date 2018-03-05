class OfferCalculator
  attr_reader :shipment, :total_price, :has_pre_carriage, :has_on_carriage, :schedules, :truck_seconds_pre_carriage, :origin_hubs, :destination_hubs, :itineraries, :itineraries_hash, :carriage_nexuses
  include CurrencyTools
  include PricingTools
  include MongoTools
  include TruckingTools
  def initialize(shipment, params, user)
    @mongo            = get_client
    @user             = user
    @shipment         = shipment
    @origin_hubs      = []
    @destination_hubs = []
    @itineraries      = []
    @itineraries_hash            = {}
    @carriage_nexuses = params[:shipment][:carriageNexuses]
    @shipment.has_pre_carriage = params[:shipment][:has_pre_carriage]
    @shipment.has_on_carriage  = params[:shipment][:has_on_carriage]
    @shipment.trucking = trucking_params(params).to_h

    @shipment.incoterm = params[:shipment][:incoterm]
    
    @truck_seconds_pre_carriage = 0
    @pricing = nil

    @current_eta_in_search = DateTime.new()
    @total_price = { total:0, currency: "EUR" }

    cargo_unit_const = @shipment.load_type.camelize.constantize
    plural_load_type = @shipment.load_type.pluralize
    @shipment.send(plural_load_type).destroy_all
    @cargo_units = cargo_unit_const.extract(send("#{plural_load_type}_params", params))
    byebug
    @shipment.send("#{plural_load_type}=", @cargo_units)

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

  def determine_route!
    @shipment.route = Route.for_locations(@shipment)
    
    raise ApplicationError::NoRoute unless @shipment.route    
  end

  def determine_itinerary!
    data  = Itinerary.for_locations(@shipment, @carriage_nexuses)
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
    schedule_obj = {}
    @itineraries.each do |itin|
      origin_layovers = itin.stops.where(hub_id: @origin_hubs).first.layovers.where("etd > ? AND etd < ?", @shipment.planned_pickup_date, @shipment.planned_pickup_date + 10.days).order(:etd).uniq
      destination_layovers = itin.stops.where(hub_id: @destination_hubs).first.layovers.where("eta > ? AND eta < ?", @shipment.planned_pickup_date, @shipment.planned_pickup_date + 2.months).order(:etd).uniq
      layovers = origin_layovers + destination_layovers
      trip_layovers = layovers.group_by(&:trip_id)
      schedule_obj[itin.id] = trip_layovers unless trip_layovers.empty?
    end
    @itineraries_hash = schedule_obj
  end

  def add_schedules_charges!
    charges = {}
    @total_price[:cargo] = { value: 0, currency: '' }
    
    @schedules.each do |sched|
      sched_key = "#{sched.hub_route.starthub_id}-#{sched.hub_route.endhub_id}"
      
      next if charges[sched_key]

      charges[sched_key] = { trucking_on: {}, trucking_pre: {}, import: {}, export: {}, cargo: {} }
      
      set_trucking_charges!(charges, sched, sched_key)
      set_cargo_charges!(charges, sched, sched_key)
    end
    @shipment.schedules_charges = charges
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
        
        set_trucking_charges!(charges, trip, sched_key)
        set_cargo_charges!(charges, trip, sched_key)
      end
    end
    
    charges.reject!{ |_, charge| charge[:cargo].empty? }
    raise ApplicationError::NoRoute if charges.empty?
    @shipment.schedules_charges = charges
  end

  def set_trucking_charges!(charges, trip, sched_key)
    if @shipment.has_pre_carriage
      charges[sched_key][:trucking_pre] = determine_trucking_options(
        @shipment.origin, 
        trip[0].stop.hub,
        'origin',
        'export'
      )
      
    end
    
    if @shipment.has_on_carriage
      charges[sched_key][:trucking_on] = determine_trucking_options(
        @shipment.destination, 
        trip[1].stop.hub,
        'destination',
        'import'
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
    @cargo_units.each do |cargo_unit|
      path_key = path_key(cargo_unit, trip)

      charge_result = send("determine_#{@shipment.load_type}_price",
        @mongo, 
        cargo_unit, 
        path_key, 
        @user, 
        @cargo_units.length
      )
      if charge_result
        charges[sched_key][:cargo][cargo_unit.id] = charge_result
      end
    end
    
  end

  def path_key(cargo_unit, trip)
    transport_category_name = cargo_unit.cargo_class ? cargo_unit.cargo_class : 'any'
    transport_category = trip[0].trip.vehicle.transport_categories.find_by(
      name: transport_category_name, 
      cargo_class: cargo_unit.try(:size_class) || 'lcl'
    )

    "#{trip[0].stop_id}_#{trip.last.stop_id}_#{transport_category.id}"
  end

  def determine_trucking_options(origin, hub, target, direction)
    google_directions = GoogleDirections.new(origin.lat_lng_string, hub.lat_lng_string, @shipment.planned_pickup_date.to_i)
    km = google_directions.distance_in_km
    truck_type = direction == 'export' ? @shipment.trucking["pre_carriage"]["truck_type"] : @shipment.trucking["on_carriage"]["truck_type"]
    # price_results = @cargo_units.map do |cargo_unit|
    #   calc_trucking_price(origin, cargo_unit, km, hub, target, @shipment.load_type, direction, @shipment.trucking)
    # end
    price_results = calc_trucking_price(origin, @cargo_units, km, hub, target, @shipment.load_type, direction, truck_type)

    # trucking_total = { value: 0, currency: "" }
    # price_results.each do |pr|
    #   trucking_total[:value] += pr[:value]
    #   trucking_total[:currency] = pr[:currency]
    # end
    # trucking_total     
  end
  
  def convert_currencies!
    
    raw_totals = {}
   
    @shipment.schedules_charges.each do |key, svalue|
      svalue["cargo"].each do |id, charges|
        if !raw_totals[charges["total"]["currency"]]
          raw_totals[charges["total"]["currency"]] = charges["total"]["value"].to_f
        else
          raw_totals[charges["total"]["currency"]] += charges["total"]["value"].to_f
        end
        
      end
      
      if !raw_totals[svalue["trucking_on"]["currency"]]
        raw_totals[svalue["trucking_on"]["currency"]] = svalue["trucking_on"]["value"].to_f
      else
        raw_totals[svalue["trucking_on"]["currency"]] += svalue["trucking_on"]["value"].to_f
      end
      
      if !raw_totals[svalue["trucking_pre"]["currency"]]
        raw_totals[svalue["trucking_pre"]["currency"]] = svalue["trucking_pre"]["value"].to_f
      else
        raw_totals[svalue["trucking_pre"]["currency"]] += svalue["trucking_pre"]["value"].to_f
      end
      converted_totals = sum_and_convert(raw_totals, @user.currency)
      @shipment.schedules_charges[key]["total"] = converted_totals

      
      if @total_price[:total] == 0 
        
        @total_price[:total] = converted_totals
      elsif @total_price[:total] > converted_totals
        @total_price[:total] = converted_totals
      end
    end
    @shipment.total_price = {value: @total_price[:total], currency: @user.currency}

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
end
