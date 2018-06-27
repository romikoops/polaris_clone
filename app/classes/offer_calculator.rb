# frozen_string_literal: true

Dir["#{Rails.root}/app/classes/offer_calculator_service/*.rb"].each { |file| require file }

class OfferCalculator
  attr_reader :shipment, :detailed_schedules, :hubs
  include CurrencyTools
  include PricingTools

  def initialize(shipment, params, user)
    @user             = user
    @shipment         = shipment
    @itineraries_hash = {}

    @delay = params[:shipment][:delay]
    @truck_seconds_pre_carriage = 0
    @current_eta_in_search = DateTime.new

    instantiate_service_classes(shipment, params)
    update_shipment
  end

  def calc_offer!
    @hubs          = @hub_finder.exec
    @trucking_data = @trucking_data_builder.exec(@hubs)
    @routes        = @route_finder.exec(@hubs)
    @routes        = @route_filter.exec(@routes)
    @schedules     = @schedule_finder.exec(@routes, @delay, @hubs)

    # TBD - Not Refactored
    add_trip_charges!
  end

  private

  def instantiate_service_classes(shipment, params)
    @shipment_update_handler = OfferCalculatorService::ShipmentUpdateHandler.new(shipment, params)
    @hub_finder              = OfferCalculatorService::HubFinder.new(shipment)
    @trucking_data_builder   = OfferCalculatorService::TruckingDataBuilder.new(shipment)
    @route_finder            = OfferCalculatorService::RouteFinder.new(shipment)
    @route_filter            = OfferCalculatorService::RouteFilter.new(shipment)
    @schedule_finder         = OfferCalculatorService::ScheduleFinder.new(shipment)
  end

  def update_shipment
    @shipment_update_handler.update_nexuses
    @shipment_update_handler.update_trucking
    @shipment_update_handler.update_incoterm
    @shipment_update_handler.update_cargo_units
    @shipment_update_handler.update_selected_day
  end

  def add_trip_charges!
    @detailed_schedules = @schedules.map do |schedule|
      destroy_previous_charge_breakdown(schedule.trip_id)
      @charge_breakdown = ChargeBreakdown.create!(shipment: @shipment, trip_id: schedule.trip_id)
      @grand_total_charge = Charge.create(
        children_charge_category: ChargeCategory.grand_total,
        charge_category:          ChargeCategory.base_node,
        charge_breakdown:         @charge_breakdown,
        price:                    Price.create(currency: @shipment.user.currency)
      )

      calc_local_charges!(schedule)
      create_trucking_charges(schedule)
      calc_cargo_charges!(schedule)
      @grand_total_charge.update_price!
      schedule.total_price = @grand_total_charge.price.as_json(only: %i(value currency))
      detailed_schedule = schedule.to_detailed_hash
      next if detailed_schedule.dig(:total_price, "value").zero?
      detailed_schedule
    end.compact

    raise ApplicationError::NoSchedulesCharges if !@grand_total_charge || @grand_total_charge.children.empty?
  end

  def calc_local_charges!(schedule)
    if @shipment.aggregated_cargo
      cargo_units = [@shipment.aggregated_cargo]
    else
      cargo_units = @shipment.cargo_units
    end
    if @shipment.has_pre_carriage || schedule.origin_hub.mandatory_charge.export_charges
      local_charges_data = determine_local_charges(
        schedule.origin_hub,
        @shipment.load_type,
        cargo_units,
        "export",
        schedule.mode_of_transport,
        schedule.trip.tenant_vehicle.id,
        schedule.destination_hub_id,
        @user
      )
      unless local_charges_data.empty?
        create_charges_from_fees_data!(local_charges_data, ChargeCategory.from_code("export"))
      end
    end
    
    if @shipment.has_on_carriage || schedule.destination_hub.mandatory_charge.import_charges
      
      local_charges_data = determine_local_charges(
        schedule.destination_hub,
        @shipment.load_type,
        cargo_units,
        "import",
        schedule.mode_of_transport,
        schedule.trip.tenant_vehicle.id,
        schedule.origin_hub_id,
        @user
      )
      
      unless local_charges_data.empty?
        create_charges_from_fees_data!(local_charges_data, ChargeCategory.from_code("import"))
      end
    end
  end

  def create_trucking_charges(schedule)
    @trucking_data.each do |carriage, data|
      charge_category = ChargeCategory.find_or_create_by(
        name: "Trucking #{carriage.capitalize}-Carriage", code: "trucking_#{carriage}"
      )

      parent_charge = create_parent_charge(charge_category)

      hub = schedule.hub_for_carriage(carriage)
      hub_data = data[hub.id]

      hub_data[:trucking_charge_data].each do |cargo_class, trucking_charges|
        children_charge_category = ChargeCategory.from_code("trucking_#{cargo_class}")
        
        create_charges_from_fees_data!(
          trucking_charges, children_charge_category, charge_category, parent_charge
        )
      end
      parent_charge.update_price!
    end
  end

  def calc_cargo_charges!(schedule)
    total_units = @shipment.cargo_units.reduce(0) do |sum, cargo_unit|
      sum + cargo_unit.try(:quantity).to_i
    end

    charge_category = ChargeCategory.from_code("cargo")
    parent_charge = create_parent_charge(charge_category)
    cargo_unit_array = @shipment.aggregated_cargo ? [@shipment.aggregated_cargo] : @shipment.cargo_units
    cargo_unit_array.each do |cargo_unit|
      charge_result = send("determine_#{@shipment.load_type}_price",
        cargo_unit,
        schedule,
        @user,
        total_units,
        @shipment.planned_pickup_date,
        schedule.mode_of_transport
      )
        
      next if charge_result.nil?

      cargo_unit_model = cargo_unit.class.to_s
      children_charge_category = ChargeCategory.find_or_create_by(
        name:          cargo_unit_model.humanize,
        code:          cargo_unit_model.underscore,
        cargo_unit_id: cargo_unit.id
      )

      create_charges_from_fees_data!(charge_result, children_charge_category, charge_category, parent_charge)
    end

    parent_charge.update_price!
  end

  def create_parent_charge(children_charge_category)
    Charge.create(
      children_charge_category: children_charge_category,
      charge_category:          ChargeCategory.grand_total,
      charge_breakdown:         @charge_breakdown,
      parent:                   @grand_total_charge,
      price:                    Price.create(currency: @shipment.user.currency)
    )
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

  def destroy_previous_charge_breakdown(trip_id)
    ChargeBreakdown.find_by(shipment: @shipment, trip_id: trip_id).try(:destroy)
  end
end
