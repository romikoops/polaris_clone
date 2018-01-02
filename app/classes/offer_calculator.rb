class OfferCalculator
  attr_reader :shipment, :total_price, :has_pre_carriage, :has_on_carriage, :schedules, :truck_seconds_pre_carriage, :origin_hubs, :destination_hubs
  include CurrencyTools
  include PricingTools
  include MongoTools
  include TruckingTools
  def initialize(shipment, params, load_type, user)
    @mongo = get_client
    @load_type = shipment.load_type
    @shipment = shipment
    @has_pre_carriage = params[:shipment][:has_pre_carriage] ? true : false
    @has_on_carriage = params[:shipment][:has_on_carriage] ? true : false
    @shipment.has_pre_carriage = @has_pre_carriage
    @shipment.has_on_carriage = @has_on_carriage
    @user = user
    case @shipment.load_type
    when 'fcl'
      @shipment.containers.destroy_all
      @containers = Container.extract_containers(params[:shipment][:containers_attributes])
      @shipment.containers = @containers
    when 'lcl'
      @shipment.cargo_items.destroy_all
      @cargo_items = CargoItem.extract_cargos(params[:shipment][:cargo_items_attributes])
      @shipment.cargo_items = @cargo_items
      @schedules = nil
    when 'openlcl'
      @shipment.cargo_items.destroy_all
      @cargo_items = CargoItem.extract_cargos(params[:shipment][:cargo_items_attributes])
      @shipment.cargo_items = @cargo_items
      @schedules = nil
    end

    @shipment.planned_pickup_date = Chronic.parse(params[:shipment][:planned_pickup_date], endian_precedence: :little)
    @shipment.origin = Location.get_geocoded_location(params[:shipment][:origin_user_input], params[:shipment][:origin_id], @has_pre_carriage)
    @shipment.destination = Location.get_geocoded_location(params[:shipment][:destination_user_input], params[:shipment][:destination_id], @has_on_carriage)

    @truck_seconds_pre_carriage = 0
    @pricing = nil
    @route = nil

    @current_eta_in_search = DateTime.new()
    @total_price = {total:0, currency: "EUR"}
  end

  def calc_offer!
    determine_route!
    
    # determine_pricing!
    
    determine_hubs!
    
    determine_longest_trucking_time!
    
    determine_schedules!
    
    # add_pre_carriage!
    
    # add_on_carriage!
    
    # add_carriage!
    
    add_service_charges!
    
    convert_currencies!
    # @shipment.total_price = @total_price
  end

  def calc_alternative_schedules!(up_to)
    begin
      up_to.times do
        @current_eta_in_search = @schedule_set_arr.last.set.first.eta + 1.second
        schedules = schedules_on_route
        @schedule_set_arr << ScheduleSet.new(schedules, @truck_seconds_pre_carriage, @has_on_carriage)
      end
    rescue
      return
    end
  end

  private

  def determine_route!
    
    @route = Route.for_locations(@shipment.origin, @shipment.destination)
    @hub_routes = @route.hub_routes
    @shipment.route = @route
  end

  def determine_pricing!
    
    if @load_type.starts_with?("open")
      @pricing = @route.pricings.get_open
    else
      
      @pricing = @route.pricings.get_dedicated(@shipment.shipper)
    end

  end

  def determine_hubs!
    @origin_hubs = []
    @destination_hubs = []
    @hub_routes.each do |hr|
      @origin_hubs << hr.starthub
      @destination_hubs << hr.endhub
    end

    @furthest_hub_from_origin = @origin_hubs.sort_by {|obj| -obj.distance_to(@shipment.origin)}.first
    @furthest_hub_to_destination = @destination_hubs.sort_by {|obj| -obj.distance_to(@shipment.destination)}.first
  end

  def determine_schedules!
    
    @schedules = @route.schedules.joins(:vehicle).joins(:transport_categories).where("transport_categories.name = 'any'").where("etd > ? AND etd < ?", @shipment.planned_pickup_date, @shipment.planned_pickup_date + 10.days)
  end

  def determine_longest_trucking_time!
    
    if @has_pre_carriage
      gd_pre_carriage = GoogleDirections.new(@shipment.origin.lat_lng_string, @furthest_hub_from_origin.lat_lng_string, @shipment.planned_pickup_date.to_i)
      car_seconds_pre_carriage = gd_pre_carriage.driving_time_in_seconds
      @longest_trucking_time = gd_pre_carriage.driving_time_in_seconds_for_trucks(car_seconds_pre_carriage)
    else
      @longest_trucking_time = 0
    end
    
    @current_eta_in_search = @shipment.planned_pickup_date + @longest_trucking_time.seconds + 3.days
  end

  

  def add_pre_carriage!
    if @has_pre_carriage
      gd_pre_carriage = GoogleDirections.new(@shipment.origin.lat_lng_string, @furthest_hub_from_origin.lat_lng_string, @shipment.planned_pickup_date.to_i)
      km = gd_pre_carriage.distance_in_km
      @shipment.pre_carriage_distance_km = km
      car_seconds_pre_carriage = gd_pre_carriage.driving_time_in_seconds
      @truck_seconds_pre_carriage = gd_pre_carriage.driving_time_in_seconds_for_trucks(car_seconds_pre_carriage)
      case @load_type
      when 'fcl'
        @containers.each do |container|
          @total_price += TruckingPricing.calc_final_price(@shipment.origin, container, km) #################
        end
      when 'lcl'
        @cargo_items.each do |cargo_item|
          
          @total_price += TruckingPricing.calc_final_price(@shipment.origin, cargo_item, km) #################
          #########################!!!!!!!!!!!!!!!!!!!
        end
      when "openlcl"
        
        @cargo_items.each do |cargo_item|
          
          @total_price += TruckingPricing.calc_final_price(@shipment.origin, cargo_item, km) #################
        end
      end
    else
      @truck_seconds_pre_carriage = 0
    end
    @current_eta_in_search = @shipment.planned_pickup_date + @truck_seconds_pre_carriage + 3.days
  end

  def add_carriage!
    ############
    @total_price[:cargo] = price_from_cargos
  end

  def add_on_carriage!
    if @has_on_carriage
      
      on_carriage_departure = @schedules.first.eta + 6.hours ##############
      gd_on_carriage = GoogleDirections.new(@furthest_hub_to_destination.lat_lng_string, @shipment.destination.lat_lng_string, on_carriage_departure.to_i)
      truck_seconds_on_carriage = gd_on_carriage.driving_time_in_seconds_for_trucks(gd_on_carriage.driving_time_in_seconds)
      eta_on_carriage = on_carriage_departure + truck_seconds_on_carriage
      km = gd_on_carriage.distance_in_km
      @shipment.on_carriage_distance_km = km
      
      case @load_type
      when 'fcl'
        @containers.each do |container|
          @total_price += TruckingPricing.calc_final_price(@shipment.destination, container, km) #################
        end
      when 'lcl'
        @cargo_items.each do |cargo_item|
          @total_price += TruckingPricing.calc_final_price(@shipment.destination, cargo_item, km) #################
          #########################!!!!!!!!!!!!!!!!!!!
        end
      when "openlcl"
        @cargo_items.each do |cargo_item|
          @total_price += TruckingPricing.calc_final_price(@shipment.destination, cargo_item, km) #################
        end
      end

    end

  end

  def add_service_charges!
    
    fees = {}
    @total_price[:cargo] = {value: 0, currency:''}
      @schedules.each do |sched|

        sched_key = "#{sched.hub_route.starthub_id}-#{sched.hub_route.endhub_id}"
        if !fees[sched_key]
          fees[sched_key] = {trucking_on: {}, trucking_pre: {}, import: {}, export:{}, cargo:{}}
          if @has_pre_carriage
          
            fees[sched_key][:trucking_pre] = determine_trucking_options(@shipment.origin, sched.hub_route.starthub)
          end
          
          if @has_on_carriage
          
            fees[sched_key][:trucking_on] = determine_trucking_options(@shipment.destination, sched.hub_route.endhub)
          end
          
          @import_charges = sched.get_service_charges("import")
          
          @export_charges = sched.get_service_charges("export")
          
          charges =  {
            import: {},
            export: {}
          }
          fees[sched_key][:import]["totals"] = {}
          fees[sched_key][:export]["totals"] = {}
          if @cargo_items
            @cargo_items.each do |ci|
              transport_type_key = ci.cargo_class ? ci.cargo_class : 'any'
              transport_type = sched.vehicle.transport_categories.find_by(name: transport_type_key, cargo_class: 'lcl')
              pathKey = "#{sched.hub_route_id}_#{transport_type.id}"
              fees[sched_key][:cargo][ci.id] = determine_lcl_price(@mongo, ci, pathKey, @user)
              
              @total_price[:cargo][:value] += fees[sched_key][:cargo][ci.id][:value]
              @total_price[:cargo][:currency] = fees[sched_key][:cargo][ci.id][:currency]
              p @import_charges
              p @export_charges
              fees[sched_key][:import][ci.id] = @import_charges.calc_import_charge(ci)
              fees[sched_key][:export][ci.id] = @export_charges.calc_export_charge(ci)
         
              p "##################################################"
              p fees[sched_key][:import][ci.id]
              p "##################################################"
              p fees[sched_key][:export][ci.id]
              fees[sched_key][:import][ci.id].each do |key, value|
                
                if !fees[sched_key][:import]["totals"][key]
                  fees[sched_key][:import]["totals"][key] = {value: 0, currency: value[:currency]}
                end
                fees[sched_key][:import]["totals"][key][:value] += value[:value]
              end
              fees[sched_key][:export][ci.id].each do |key, value|
                
                if !fees[sched_key][:export]["totals"][key]
                  fees[sched_key][:export]["totals"][key] = {value: 0, currency: value[:currency]}
                end
                fees[sched_key][:export]["totals"][key][:value] += value[:value]
              end

            end
          end
          
          if @containers
            @containers.each do |cnt|
              transport_type_key = cnt.cargo_class ? cnt.cargo_class : 'any'
              
              transport_type = sched.vehicle.transport_categories.find_by(name: transport_type_key, cargo_class: cnt.size_class)
              pathKey = "#{sched.hub_route_id}_#{transport_type.id}"
              fees[sched_key][:cargo][cnt.id] = determine_fcl_price(@mongo, cnt, pathKey, @user)
              @total_price[:cargo][:value] += fees[sched_key][:cargo][cnt.id][:value]
              @total_price[:cargo][:currency] = fees[sched_key][:cargo][cnt.id][:currency]
            # @containers.each do |cnt|
            #   fees[sched_key][:import][cnt.id] = @import_charges.calc_import_charge(cnt)
            #   fees[sched_key][:export][cnt.id] = @export_charges.calc_export_charge(cnt)
            end
          end
          
        end
      end
      
        @shipment.generated_fees = fees
    end
    def determine_trucking_options(origin, hub)
      gd_pre_carriage = GoogleDirections.new(origin.lat_lng_string, hub.lat_lng_string, @shipment.planned_pickup_date.to_i)
      km = gd_pre_carriage.distance_in_km
      byebug
      price_results = []    
      case @load_type
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
      if svalue["import"]["totals"] != {}
          svalue["import"]["totals"].each do |key, fee|
          
          if !raw_totals[fee["currency"]]
            raw_totals[fee["currency"]] = fee["value"]
          else
            raw_totals[fee["currency"]] += fee["value"]
          end
        end
      end
        
      if svalue["export"]["totals"] != {}  
        svalue["export"]["totals"].each do |key, fee|
          
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
      if !raw_totals[@total_price[:cargo][:currency]]
        raw_totals[@total_price[:cargo][:currency]] = @total_price[:cargo][:value].to_f
      else
        raw_totals[@total_price[:cargo][:currency]] += @total_price[:cargo][:value].to_f
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
    stop1 = Location.find(@route.origin_nexus_id)
    stop2 = Location.find(@route.destination_nexus_id)

    mode_of_transport = Route.get_mode_of_transport(stop1, stop2)
    Schedule.where(mode_of_transport: mode_of_transport, from: stop1.hub_name, to: stop2.hub_name)
    .where("eta > ?", @current_eta_in_search)
    .order(eta: :asc)
    # case mode_of_transport
    # when "train"
    #   Schedule.where(mode_of_transport: mode_of_transport, from: stop1.hub_name, to: stop2.hub_name)
    #                .where("eta > ?", @current_eta_in_search)
    #                .order(eta: :asc)
    # when "vessel"
    #   Schedule.where(from: stop1.hub_name, to: stop2.hub_name)
    #                 .where("eta > ?", @current_eta_in_search)
    #                 .order(eta: :asc)
    # end
  end

  def price_from_cargos
    prices = []
    
    case @load_type
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
