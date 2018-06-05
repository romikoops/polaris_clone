# frozen_string_literal: true

class OfferCalculator
  attr_reader :shipment, :total_price, :has_pre_carriage, :has_on_carriage, :schedules, :truck_seconds_pre_carriage, :origin_hubs, :destination_hubs, :itineraries, :itineraries_hash, :delay, :trucking_data
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

    # Setting trucking also sets has_on_carriage and has_pre_carriage
    @shipment.trucking = trucking_params(params).to_h

    @delay = params[:shipment][:delay]
    @shipment.incoterm_id = params[:shipment][:incoterm]
    @trucking_data = {}
    @truck_seconds_pre_carriage = 0

    @current_eta_in_search = DateTime.new
    @total_price = { total: 0, currency: 'EUR' }

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

    date = Chronic.parse(params[:shipment][:selected_day], endian_precedence: :little)
    date_limit = Date.today + 5.days
    @selected_day_attribute = @shipment.has_on_carriage? ? :planned_pickup_date : :planned_origin_drop_off_date
    @shipment[@selected_day_attribute] = [date, date_limit].min

    @shipment.origin_nexus_id = params[:shipment][:origin][:nexus_id]
    if @shipment.has_pre_carriage?

      @pickup_address = Location.create_from_raw_params!(location_params(params, :origin))

      raise ApplicationError::InvalidPickupAddress unless @pickup_address
      @shipment.trucking['pre_carriage']['location_id'] = @pickup_address.id
    end

    @shipment.destination_nexus_id = params[:shipment][:destination][:nexus_id]
    if @shipment.has_on_carriage?
      @delivery_address = Location.create_from_raw_params!(location_params(params, :destination))
      raise ApplicationError::InvalidDeliveryAddress unless @delivery_address
      @shipment.trucking['on_carriage']['location_id'] = @delivery_address.id
    end
  end

  def calc_offer!
    determine_trucking_options!

    determine_itinerary!
    determine_current_etd_in_search!

    determine_layovers!
    add_trip_charges!
    convert_currencies!
    prep_schedules!
  end

  private

  def determine_itinerary!
    data = Itinerary.for_locations(@shipment, @trucking_data)
    @itineraries = data[:itineraries]
    filter_itineraries!

    raise ApplicationError::NoRoute if @itineraries.nil?

    @origin_hubs = data[:origin_hubs]
    @destination_hubs = data[:destination_hubs]
  end

  def filter_itineraries!
    return unless @cargo_units.first.is_a? CargoItem

    @itineraries.select! do |itinerary|
      @cargo_units.all? { |cargo_item| cargo_item.valid_for_itinerary?(itinerary) } &&
        @shipment.valid_for_itinerary?(itinerary)
    end
  end

  def determine_current_etd_in_search!
    longest_trucking_time = 0

    if shipment.has_pre_carriage?
      google_directions = GoogleDirections.new(
        @pickup_address.lat_lng_string,
        @pickup_address.furthest_hub(@origin_hubs).lat_lng_string,
        @shipment.planned_pickup_date.to_i
      )

      driving_time = google_directions.driving_time_in_seconds
      longest_trucking_time = google_directions.driving_time_in_seconds_for_trucks(driving_time)
    end
    @current_etd_in_search = @shipment[@selected_day_attribute] + longest_trucking_time.seconds + 3.days
  rescue StandardError
    raise ApplicationError::NoTruckingTime
  end

  def determine_layovers!
    delay = @delay ? @delay.to_i : 20
    schedule_obj = {}
    @itineraries.each do |itin|
      destination_stop = itin.stops.where(hub_id: @destination_hubs).first
      origin_stop = itin.stops.where(hub_id: @origin_hubs).first
      origin_layovers = origin_stop.layovers.where(
        'closing_date > ? AND closing_date < ?',
        @current_etd_in_search,
        @current_etd_in_search + delay.days
      ).order(:etd).uniq

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

      next unless trip && trip.length > 1
      sched_key = "#{trip[0].stop.hub_id}-#{trip[1].stop.hub_id}"

      next if charges[sched_key]

      charges[sched_key] = { trucking_on: {}, trucking_pre: {}, import: {}, export: {}, cargo: {} }
      @charge_breakdown = ChargeBreakdown.create!(shipment: @shipment, itinerary_id: itinerary_id)
      @grand_total_charge = Charge.create(
        children_charge_category: ChargeCategory.grand_total,
        charge_category: ChargeCategory.base_node,
        charge_breakdown: @charge_breakdown,
        price: Price.create(currency: @shipment.user.currency)
      )

      set_local_charges!(charges, trip, sched_key)
      set_trucking_charges!(charges, trip, sched_key)

      itinerary = @itineraries.select { |it| it.id == itinerary_id }.first
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
        @pickup_address,
        trip[0].stop.hub,
        'origin',
        'export'
      )
      create_charges_from_fees_data!(
        trucking_fees_data,
        ChargeCategory.create(name: 'Trucking Pre-Carriage', code: 'trucking_pre')
      )

      charges[sched_key][:trucking_pre] = trucking_fees_data
    end

    if @shipment.has_on_carriage?
      trucking_fees_data = determine_trucking_fees(
        @delivery_address,
        trip[1].stop.hub,
        'destination',
        'import'
      )
      create_charges_from_fees_data!(
        trucking_fees_data,
        ChargeCategory.create(name: 'Trucking On-Carriage', code: 'trucking_on')
      )
      charges[sched_key][:trucking_on] = trucking_fees_data
    end
  end

  def set_local_charges!(charges, trip, sched_key)
    if @shipment.has_pre_carriage || trip[0].stop.hub.mandatory_charge.export_charges
      local_charges_data = determine_local_charges(
        trip[0].stop.hub,
        @shipment.load_type,
        @cargo_units,
        'export',
        trip[0].itinerary.mode_of_transport,
        @user
      )
      create_charges_from_fees_data!(local_charges_data, ChargeCategory.from_code('export'))

      charges[sched_key][:export] = local_charges_data
    end

    if @shipment.has_on_carriage || trip[1].stop.hub.mandatory_charge.import_charges
      local_charges_data = determine_local_charges(
        trip[1].stop.hub,
        @shipment.load_type,
        @cargo_units,
        'import',
        trip[1].itinerary.mode_of_transport,
        @user
      )
      create_charges_from_fees_data!(local_charges_data, ChargeCategory.from_code('import'))

      charges[sched_key][:import] = local_charges_data
    end
  end

  def prep_schedules!
    schedules = []

    @itineraries_hash.each do |iKey, iValue|
      iValue.each do |tKey, tValue|
        next unless tValue.length > 1 && @shipment.schedules_charges["#{tValue[0].stop.hub_id}-#{tValue[1].stop.hub_id}"]
        schedules.push(
          id: SecureRandom.uuid,
          total: @shipment.schedules_charges["#{tValue[0].stop.hub_id}-#{tValue[1].stop.hub_id}"]['total'],
          itinerary_id: iKey,
          eta: tValue[1].eta,
          etd: tValue[0].etd,
          closing_date: tValue[0].closing_date,
          mode_of_transport: tValue[0].itinerary.mode_of_transport,
          hub_route_key: "#{tValue[0].stop.hub_id}-#{tValue[1].stop.hub_id}",
          tenant_id: @shipment.tenant_id,
          trip_id: tKey,
          origin_layover_id: tValue[0].id,
          destination_layover_id: tValue[1].id
        )
      end
    end
    @schedules = schedules
  end

  def set_cargo_charges!(charges, trip, sched_key, mot)
    total_units = @cargo_units.reduce(0) { |sum, cargo_unit| sum += cargo_unit.try(:quantity).to_i }

    charge_category = ChargeCategory.from_code('cargo')
    parent_charge = Charge.create(
      children_charge_category: charge_category,
      charge_category: ChargeCategory.grand_total,
      charge_breakdown: @charge_breakdown,
      parent: @grand_total_charge,
      price: Price.create(currency: @shipment.user.currency)
    )

    @cargo_units.each do |cargo_unit|
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
        name: cargo_unit_model.humanize,
        code: cargo_unit_model.underscore,
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
    charge_category = ChargeCategory.grand_total,
    parent = @grand_total_charge
  )
    parent_charge = Charge.create(
      children_charge_category: children_charge_category,
      charge_category: charge_category,
      charge_breakdown: @charge_breakdown,
      parent: parent,
      price: Price.create(fees_data['total'] || fees_data[:total])
    )

    fees_data.each do |code, charge|
      next if code.to_s == 'total' || charge.empty?

      Charge.create(
        children_charge_category: ChargeCategory.from_code(code),
        charge_category: children_charge_category,
        charge_breakdown: @charge_breakdown,
        parent: parent_charge,
        price: Price.create(charge)
      )
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
    if @shipment.has_pre_carriage?
      trucking_pricings = TruckingPricing.find_by_filter(
        location: @pickup_address,
        load_type: load_type,
        tenant_id: @user.tenant_id,
        truck_type: @shipment.trucking['pre_carriage']['truck_type'],
        carriage: 'pre'
      )
      @trucking_data['pre_carriage'] = {}
      trucking_pricings.each do |trucking_pricing|
        @trucking_data['pre_carriage'][trucking_pricing.hub_id] = trucking_pricing
      end
    end

    if @shipment.has_on_carriage?
      trucking_pricings = TruckingPricing.find_by_filter(
        location: @delivery_address,
        load_type: load_type,
        tenant_id: @user.tenant_id,
        truck_type: @shipment.trucking['on_carriage']['truck_type'],
        carriage: 'on'
      )
      @trucking_data['on_carriage'] = {}
      trucking_pricings.each do |trucking_pricing|
        @trucking_data['on_carriage'][trucking_pricing.hub_id] = trucking_pricing
      end
    end
  end

  def determine_trucking_fees(location, hub, _target, direction)
    google_directions = GoogleDirections.new(location.lat_lng_string, hub.lat_lng_string, @shipment.planned_pickup_date.to_i)
    km = google_directions.distance_in_km
    carriage = direction == 'import' ? 'on_carriage' : 'pre_carriage'
    trucking_pricing = @trucking_data[carriage][hub.id]
    price_results = calc_trucking_price(trucking_pricing, @cargo_units, km, direction)
  end

  def convert_currencies!
    @shipment.schedules_charges.each do |key, svalue|
      raw_totals = {}
      svalue['cargo'].each do |_id, charges|
        if !raw_totals[charges['total']['currency']]
          raw_totals[charges['total']['currency']] = charges['total']['value'].to_d
        else
          raw_totals[charges['total']['currency']] += charges['total']['value'].to_d
        end
      end

      unless svalue['import'].empty?
        if !raw_totals[svalue['import']['total']['currency']]
          raw_totals[svalue['import']['total']['currency']] = svalue['import']['total']['value'].to_d
        else
          raw_totals[svalue['import']['total']['currency']] += svalue['import']['total']['value'].to_d
        end
      end

      unless svalue['export'].empty?
        if !raw_totals[svalue['export']['total']['currency']]
          raw_totals[svalue['export']['total']['currency']] = svalue['export']['total']['value'].to_d
        else
          raw_totals[svalue['export']['total']['currency']] += svalue['export']['total']['value'].to_d
        end
      end

      if svalue['trucking_on'] && svalue['trucking_on']['total']
        if !raw_totals[svalue['trucking_on']['total']['currency']]
          raw_totals[svalue['trucking_on']['total']['currency']] = svalue['trucking_on']['total']['value'].to_f
        else
          raw_totals[svalue['trucking_on']['total']['currency']] += svalue['trucking_on']['total']['value'].to_f
        end
      end

      if svalue['trucking_pre'] && svalue['trucking_pre']['total']
        if !raw_totals[svalue['trucking_pre']['total']['currency']]
          raw_totals[svalue['trucking_pre']['total']['currency']] = svalue['trucking_pre']['total']['value'].to_f
        else
          raw_totals[svalue['trucking_pre']['total']['currency']] += svalue['trucking_pre']['total']['value'].to_f
        end
      end

      converted_totals = sum_and_convert(raw_totals, @user.currency)
      @shipment.schedules_charges[key]['total'] = { value: converted_totals, currency: @user.currency }

      if @total_price[:total] == 0
        @total_price[:total] = converted_totals
      elsif @total_price[:total] > converted_totals
        @total_price[:total] = converted_totals
      end
    end

    @shipment.total_price = { value: @total_price[:total], currency: @user.currency }
  end

  private

  def trucking_params(params)
    params.require(:shipment).require(:trucking).permit(
      on_carriage: :truck_type, pre_carriage: :truck_type
    )
  end

  def cargo_items_params(params)
    params.require(:shipment).permit(
      cargo_items_attributes: %i[
        payload_in_kg dimension_x dimension_y dimension_z
        quantity cargo_item_type_id dangerous_goods stackable
      ]
    )[:cargo_items_attributes]
  end

  def containers_params(params)
    params.require(:shipment).permit(
      containers_attributes: %i[
        payload_in_kg sizeClass tareWeight quantity dangerous_goods
      ]
    )[:containers_attributes].map do |container_attributes|
      container_attributes.to_h.deep_transform_keys { |k| k.to_s.underscore }
    end
  end

  def aggregated_cargo_params(params)
    params.require(:shipment).require(:aggregated_cargo_attributes).permit(:weight, :volume)
  end

  def location_params(params, target)
    unsafe_location_hash = params.require(:shipment).require(target).to_unsafe_hash
    snakefied_location_hash = unsafe_location_hash.deep_transform_keys { |k| k.to_s.underscore }
    snakefied_location_hash[:geocoded_address] = snakefied_location_hash.delete(:full_address)
    snakefied_location_hash[:street_number] = snakefied_location_hash.delete(:number)
    snakefied_location_params = ActionController::Parameters.new(snakefied_location_hash)
  end
end
