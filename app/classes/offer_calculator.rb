class OfferCalculator
  attr_reader :shipment, :total_price, :has_pre_carriage, :has_on_carriage, :schedules, :truck_seconds_pre_carriage, :origin_hubs, :destination_hubs
  include CurrencyTools
  include PricingTools
  include MongoTools
  include TruckingTools
  def initialize(shipment, params, load_type, user)
    @mongo            = get_client
    @user             = user
    @shipment         = shipment
    @origin_hubs      = []
    @destination_hubs = []

    @shipment.has_pre_carriage = params[:shipment][:has_pre_carriage] ? true : false
    @shipment.has_on_carriage  = params[:shipment][:has_on_carriage]  ? true : false   
    
    @truck_seconds_pre_carriage = 0
    @pricing = nil

    @current_eta_in_search = DateTime.new()
    @total_price = { total:0, currency: "EUR" }

    case @shipment.load_type
    when 'fcl'
      @shipment.containers.destroy_all
      @containers = Container.extract_containers(params[:shipment][:containers_attributes])
      @shipment.containers = @containers
    when 'lcl', 'openlcl'
      @shipment.cargo_items.destroy_all
      @cargo_items = CargoItem.extract_cargos(params[:shipment][:cargo_items_attributes])
      @shipment.cargo_items = @cargo_items
      @schedules = nil
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
    @shipment.destination = Location.get_geocoded_location(
      params[:shipment][:destination_user_input],
      params[:shipment][:destination_id],
      shipment.has_on_carriage
    )
  end

  def calc_offer!
    determine_route!
    determine_hubs!    
    determine_longest_trucking_time!
    determine_schedules!
    
    add_service_charges!
    
    convert_currencies!
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
    @shipment.route = Route.for_locations(@shipment.origin, @shipment.destination)
  end

  def determine_hubs!
    @shipment.route.hub_routes.each do |hub_route|
      @origin_hubs      << hub_route.starthub
      @destination_hubs << hub_route.endhub
    end

    @furthest_hub_from_origin    = @shipment.origin.furthest_hub(@origin_hubs)
    @furthest_hub_to_destination = @shipment.destination.furthest_hub(@destination_hubs)
  end

  def determine_longest_trucking_time!
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
  end

  def determine_schedules! 
    @schedules = @shipment.route.schedules.joins(:vehicle).joins(:transport_categories)
      .where("transport_categories.name = 'any'")
      .where("etd > ? AND etd < ?", @shipment.planned_pickup_date, @shipment.planned_pickup_date + 10.days)
  end

  def add_service_charges!
    
    fees = {}
    @total_price[:cargo] = {value: 0, currency:''}
      @schedules.each do |sched|

        sched_key = "#{sched.hub_route.starthub_id}-#{sched.hub_route.endhub_id}"
        if !fees[sched_key]
          fees[sched_key] = {trucking_on: {}, trucking_pre: {}, import: {}, export:{}, cargo:{}}
          if shipment.has_pre_carriage
          
            fees[sched_key][:trucking_pre] = determine_trucking_options(@shipment.origin, sched.hub_route.starthub)
          end
          
          if shipment.has_on_carriage
          
            fees[sched_key][:trucking_on] = determine_trucking_options(@shipment.destination, sched.hub_route.endhub)
          end
          if @cargo_items
            @cargo_items.each do |ci|
              transport_type_key = ci.cargo_class ? ci.cargo_class : 'any'
              transport_type = sched.vehicle.transport_categories.find_by(name: transport_type_key, cargo_class: 'lcl')
              pathKey = "#{sched.hub_route_id}_#{transport_type.id}"
              fees[sched_key][:cargo][ci.id] = determine_lcl_price(@mongo, ci, pathKey, @user, @cargo_items.length)
              
            end
          end
          
          if @containers
            @containers.each do |cnt|
              transport_type_key = cnt.cargo_class ? cnt.cargo_class : 'any'
              
              transport_type = sched.vehicle.transport_categories.find_by(name: transport_type_key, cargo_class: cnt.size_class)
              pathKey = "#{sched.hub_route_id}_#{transport_type.id}"
              fees[sched_key][:cargo][cnt.id] = determine_fcl_price(@mongo, cnt, pathKey, @user, @containers.length)
            end
          end
          
        end
      end
      
        @shipment.generated_fees = fees
    end
    def determine_trucking_options(origin, hub)
      google_directions = GoogleDirections.new(origin.lat_lng_string, hub.lat_lng_string, @shipment.planned_pickup_date.to_i)
      km = google_directions.distance_in_km
      price_results = []    

      case shipment.load_type
      when 'fcl'
        @containers.each do |container|
          price_results << calc_trucking_price(origin, container, km, hub, @mongo) #################
        end
      when 'lcl'
        @cargo_items.each do |cargo_item|
          
          price_results << calc_trucking_price(origin, cargo_item, km, hub, @mongo) #################
          #########################!!!!!!!!!!!!!!!!!!!
        end
      when "openlcl"
        
        @cargo_items.each do |cargo_item|
          
          price_results << calc_trucking_price(origin, cargo_item, km, hub, @mongo) #################
        end
      end
      trucking_total = {value: 0, currency:""}
      price_results.each do |pr|
        trucking_total[:value] += pr[:value]
        trucking_total[:currency] = pr[:currency]
      end
      trucking_total
     
  end
  
  def convert_currencies!
    
    raw_totals = {}
   
    @shipment.generated_fees.each do |key, svalue|
      svalue["cargo"].each do |id, fees|
        fees.each do |fid, fee|
           if !raw_totals[fee["currency"]]
            raw_totals[fee["currency"]] = fee["value"].to_f
          else
            raw_totals[fee["currency"]] += fee["value"].to_f
          end
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
      
      
      converted_totals = sum_and_convert(raw_totals, "EUR")
      @shipment.generated_fees[key]["total"] = converted_totals
      
      if @total_price[:total] == 0 
        
        @total_price[:total] = converted_totals
      elsif @total_price[:total] > converted_totals
        @total_price[:total] = converted_totals
      end
    end
    @shipment.total_price = @total_price[:total]
  end

  def schedules_on_route
    stop1 = Location.find(@shipment.route.origin_nexus_id)
    stop2 = Location.find(@shipment.route.destination_nexus_id)

    mode_of_transport = Route.get_mode_of_transport(stop1, stop2)
    Schedule.where(mode_of_transport: mode_of_transport, from: stop1.hub_name, to: stop2.hub_name)
      .where("eta > ?", @current_eta_in_search)
      .order(eta: :asc)
  end

  def price_from_cargos
    prices = []
    
    case shipment.load_type
    when 'fcl'
      @containers.each do |container|
        price = Pricing.fcl_price(container)

        prices << price
      end
    when 'lcl'
      @cargo_items.each do |cargo|
        price = Pricing.lcl_price(cargo)

        prices << price
      end
    when 'openlcl'
      @cargo_items.each do |cargo|
        price = Pricing.lcl_price(cargo)
        prices << price
      end
    end

    total_price_obj = { value: prices.map{ |p| p[:value]}.reduce(0, :+), currency: prices[0][:currency] }
  end
end
