# frozen_string_literal: true

Dir["#{Rails.root}/app/classes/offer_calculator_service/*.rb"].each { |file| require file }

class OfferCalculator
  attr_reader :shipment, :total_price, :has_pre_carriage, :has_on_carriage, :schedules, :truck_seconds_pre_carriage, :origin_hubs, :destination_hubs, :itineraries_hash, :delay, :trucking_data
  include CurrencyTools
  include PricingTools
  include TruckingTools

  def initialize(shipment, params, user)
    @user             = user
    @shipment         = shipment
    @itineraries      = []
    @itineraries_hash = {}

    @delay = params[:shipment][:delay]
    @truck_seconds_pre_carriage = 0
    @current_eta_in_search = DateTime.new

    instantiate_service_classes(shipment, params)
    update_shipment
  end

  def calc_offer!
    @trucking_pricings = @trucking_pricing_finder.exec
    @hubs              = @hub_finder.exec(@trucking_pricings)
    @routes            = @route_finder.exec(@hubs)
    @routes            = @route_filter.exec(@routes)

    # Temporarily here for legacy code to work
    @origin_hubs      = @hubs[:origin]
    @destination_hubs = @hubs[:destination]

    # TBD - Not Refactored
    determine_current_etd_in_search!
    determine_layovers!
    add_trip_charges!
    convert_currencies!
    prep_schedules!
  end

  private

  def instantiate_service_classes(shipment, params)
    @shipment_update_handler = OfferCalculatorService::ShipmentUpdateHandler.new(shipment, params)
    @trucking_pricing_finder = OfferCalculatorService::TruckingPricingFinder.new(shipment)
    @hub_finder              = OfferCalculatorService::HubFinder.new(shipment)
    @route_finder            = OfferCalculatorService::RouteFinder.new(shipment)
    @route_filter            = OfferCalculatorService::RouteFilter.new(shipment)
  end

  def update_shipment
    @shipment_update_handler.update_nexuses
    @shipment_update_handler.update_trucking
    @shipment_update_handler.update_incoterm
    @shipment_update_handler.update_cargo_units
    @shipment_update_handler.update_selected_day
  end

  def determine_current_etd_in_search!
    longest_trucking_time = 0

    if shipment.has_pre_carriage?
      google_directions = GoogleDirections.new(
        @shipment.pickup_address.lat_lng_string,
        @shipment.pickup_address.furthest_hub(@origin_hubs).lat_lng_string,
        @shipment.planned_pickup_date.to_i
      )

      driving_time = google_directions.driving_time_in_seconds
      longest_trucking_time = google_directions.driving_time_in_seconds_for_trucks(driving_time)
    end
    @current_etd_in_search = @shipment.selected_day + longest_trucking_time.seconds + 3.days
  rescue StandardError
    raise ApplicationError::NoTruckingTime
  end

  def determine_layovers!
    delay = @delay ? @delay.to_i : 20
    schedule_obj = {}
    @routes.each do |route|
      destination_stop = Stop.find(route.destination_stop_id)
      origin_stop      = Stop.find(route.origin_stop_id)
      origin_layovers = origin_stop.layovers.where(
        "closing_date > ? AND closing_date < ?",
        @current_etd_in_search,
        @current_etd_in_search + delay.days
      ).order(:etd).uniq

      trip_layovers = origin_layovers.each_with_object({}) do |ol, return_hash|
        return_hash[ol.trip_id] = [
          ol,
          Layover.find_by(trip_id: ol.trip_id, stop_id: destination_stop.id)
        ]
      end
      schedule_obj[route.itinerary_id] = trip_layovers unless trip_layovers.empty?
    end

    @itineraries_hash = schedule_obj
  end

  def add_trip_charges!
    charges = {}
    @total_price = { total: 0, currency: "EUR" }
    @total_price[:cargo] = { value: 0, currency: "" }

    @itineraries_hash.select! do |itinerary_id, trips|
      trip = trips.values.first

      next unless trip && trip.length > 1
      sched_key = "#{trip[0].stop.hub_id}-#{trip[1].stop.hub_id}"

      next if charges[sched_key]

      charges[sched_key] = { trucking_on: {}, trucking_pre: {}, import: {}, export: {}, cargo: {} }

      destroy_previous_charge_breakdown(itinerary_id)
      @charge_breakdown = ChargeBreakdown.create!(shipment: @shipment, itinerary_id: itinerary_id)
      @grand_total_charge = Charge.create(
        children_charge_category: ChargeCategory.grand_total,
        charge_category:          ChargeCategory.base_node,
        charge_breakdown:         @charge_breakdown,
        price:                    Price.create(currency: @shipment.user.currency)
      )

      set_local_charges!(charges, trip, sched_key)
      set_trucking_charges!(charges, trip, sched_key)

      itinerary = Itinerary.find(itinerary_id)
      set_cargo_charges!(charges, trip, sched_key, itinerary.mode_of_transport)

      @grand_total_charge.update_price!
    end

    charges.reject! { |_, charge| charge[:cargo].empty? }
    raise ApplicationError::NoSchedulesCharges if charges.empty?
    @shipment.schedules_charges = charges
  end

  def set_trucking_charges!(charges, trip, sched_key)
    if @shipment.has_pre_carriage?
      trucking_fees_data = determine_trucking_fees(
        @shipment.pickup_address,
        trip[0].stop.hub,
        "origin",
        "export"
      )
      create_charges_from_fees_data!(
        trucking_fees_data,
        ChargeCategory.create(name: "Trucking Pre-Carriage", code: "trucking_pre")
      )

      charges[sched_key][:trucking_pre] = trucking_fees_data
    end

    if @shipment.has_on_carriage?
      trucking_fees_data = determine_trucking_fees(
        @shipment.delivery_address,
        trip[1].stop.hub,
        "destination",
        "import"
      )
      create_charges_from_fees_data!(
        trucking_fees_data,
        ChargeCategory.create(name: "Trucking On-Carriage", code: "trucking_on")
      )
      charges[sched_key][:trucking_on] = trucking_fees_data
    end
  end

  def set_local_charges!(charges, trip, sched_key)
    if @shipment.has_pre_carriage || trip[0].stop.hub.mandatory_charge.export_charges
      local_charges_data = determine_local_charges(
        trip[0].stop.hub,
        @shipment.load_type,
        @shipment.cargo_units,
        "export",
        trip[0].itinerary.mode_of_transport,
        @user
      )
      unless local_charges_data.empty?
        create_charges_from_fees_data!(local_charges_data, ChargeCategory.from_code('export'))
      end
      charges[sched_key][:export] = local_charges_data
    end

    if @shipment.has_on_carriage || trip[1].stop.hub.mandatory_charge.import_charges
      local_charges_data = determine_local_charges(
        trip[1].stop.hub,
        @shipment.load_type,
        @shipment.cargo_units,
        "import",
        trip[1].itinerary.mode_of_transport,
        @user
      )
      unless local_charges_data.empty?
        create_charges_from_fees_data!(local_charges_data, ChargeCategory.from_code('import'))
      end
      charges[sched_key][:import] = local_charges_data
    end
  end

  def prep_schedules!
    schedules = []

    @itineraries_hash.each do |iKey, iValue|
      iValue.each do |tKey, tValue|
        next unless tValue.length > 1 && @shipment.schedules_charges["#{tValue[0].stop.hub_id}-#{tValue[1].stop.hub_id}"]
        schedules.push(
          id:                     SecureRandom.uuid,
          total:                  @shipment.schedules_charges["#{tValue[0].stop.hub_id}-#{tValue[1].stop.hub_id}"]["total"],
          itinerary_id:           iKey,
          eta:                    tValue[1].eta,
          etd:                    tValue[0].etd,
          closing_date:           tValue[0].closing_date,
          mode_of_transport:      tValue[0].itinerary.mode_of_transport,
          hub_route_key:          "#{tValue[0].stop.hub_id}-#{tValue[1].stop.hub_id}",
          tenant_id:              @shipment.tenant_id,
          trip_id:                tKey,
          origin_layover_id:      tValue[0].id,
          destination_layover_id: tValue[1].id
        )
      end
    end
    @schedules = schedules
  end

  def set_cargo_charges!(charges, trip, sched_key, mot)
    total_units = @shipment.cargo_units.reduce(0) do |sum, cargo_unit|
      sum + cargo_unit.try(:quantity).to_i
    end

    charge_category = ChargeCategory.from_code("cargo")
    parent_charge = Charge.create(
      children_charge_category: charge_category,
      charge_category:          ChargeCategory.grand_total,
      charge_breakdown:         @charge_breakdown,
      parent:                   @grand_total_charge,
      price:                    Price.create(currency: @shipment.user.currency)
    )

    @shipment.cargo_units.each do |cargo_unit|
      path_key = path_key(cargo_unit, trip)

      charge_result = send("determine_#{@shipment.load_type}_price",
        cargo_unit,
        path_key,
        @user,
        total_units,
        @shipment.planned_pickup_date,
        mot)
        
      next if charge_result.nil?

      cargo_unit_model = cargo_unit.class.to_s
      children_charge_category = ChargeCategory.find_or_create_by(
        name:          cargo_unit_model.humanize,
        code:          cargo_unit_model.underscore,
        cargo_unit_id: cargo_unit.id
      )

      create_charges_from_fees_data!(charge_result, children_charge_category, charge_category, parent_charge)

      charges[sched_key][:cargo][cargo_unit.id] = charge_result
    end

    parent_charge.update_price!
  end

  def create_charges_from_fees_data!(
    fees_data,
    children_charge_category,
    charge_category=ChargeCategory.grand_total,
    parent=@grand_total_charge
  )
    parent_charge = Charge.create(
      children_charge_category: children_charge_category,
      charge_category:          charge_category,
      charge_breakdown:         @charge_breakdown,
      parent:                   parent,
      price:                    Price.create(fees_data["total"] || fees_data[:total])
    )
      
    fees_data.each do |code, charge|
      next if code.to_s == "total" || charge.empty?

      Charge.create(
        children_charge_category: ChargeCategory.from_code(code),
        charge_category:          children_charge_category,
        charge_breakdown:         @charge_breakdown,
        parent:                   parent_charge,
        price:                    Price.create(charge)
      )
    end
  end

  def path_key(cargo_unit, layovers)
    transport_category = layovers[0].trip.tenant_vehicle.vehicle.transport_categories.find_by(
      name:              "any",
      cargo_class:       cargo_unit.try(:size_class) || "lcl",
      mode_of_transport: layovers[0].trip.itinerary.mode_of_transport
    )
      
    "#{layovers[0].stop_id}_#{layovers.last.stop_id}_#{transport_category.id}"
  end

  def determine_trucking_fees(location, hub, _target, direction)
    google_directions = GoogleDirections.new(location.lat_lng_string, hub.lat_lng_string, @shipment.planned_pickup_date.to_i)
    km = google_directions.distance_in_km
    carriage = direction == "import" ? "on_carriage" : "pre_carriage"
    trucking_pricing = @trucking_data[carriage][hub.id]
    price_results = calc_trucking_price(trucking_pricing, @shipment.cargo_units, km, direction)
  end

  def convert_currencies!
    @shipment.schedules_charges.each do |key, svalue|
      raw_totals = {}
      svalue["cargo"].each do |_id, charges|
        if !raw_totals[charges["total"]["currency"]]
          raw_totals[charges["total"]["currency"]] = charges["total"]["value"].to_d
        else
          raw_totals[charges["total"]["currency"]] += charges["total"]["value"].to_d
        end
      end

      unless svalue["import"].empty?
        if !raw_totals[svalue["import"]["total"]["currency"]]
          raw_totals[svalue["import"]["total"]["currency"]] = svalue["import"]["total"]["value"].to_d
        else
          raw_totals[svalue["import"]["total"]["currency"]] += svalue["import"]["total"]["value"].to_d
        end
      end

      unless svalue["export"].empty?
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

  def destroy_previous_charge_breakdown(itinerary_id)
    ChargeBreakdown.find_by(shipment: @shipment, itinerary_id: itinerary_id).try(:destroy)
  end
end
