# frozen_string_literal: true

module PriceCheckerService
  class PriceChecker
    include CurrencyTools
    include PricingTools

    def initialize(itinerary, shipment_data, user)
      @itinerary     = Itinerary.find(itinerary)
      @origin_hub    = @itinerary.first_stop.hub
      @destination_hub = @itinerary.last_stop.hub
      @shipment_data = shipment_data
      @user          = user
      @trucking_data = shipment_data[:trucking] || {}
      @service_level = shipment_data[:service_level]
      @cargo_units = cargo_unit_const.extract(@shipment_data[:cargo_units])
    end

    def perform
      prep_faux_schedules
      @results = @schedules.map do |schedule|
        @schedule = schedule
        @grand_total_charge = Charge.create(
          children_charge_category: ChargeCategory.grand_total,
          charge_category:          ChargeCategory.base_node,
          price:                    Price.create(currency: @user.currency)
        )

        calc_local_charges
        create_trucking_charges
        calc_cargo_charges
        @grand_total_charge.update_quote_price!(@itinerary.tenant_id)
        @grand_total_charge.save
        { quote: @grand_total_charge, service_level: @schedule.trip.tenant_vehicle }
      end
    end

    private

    def prep_faux_schedules
      if !@service_level
        tv_ids = {}
        unique_trips = @itinerary.trips.select do |trip|
          unless tv_ids[trip.tenant_vehicle_id]
            tv_ids[trip.tenant_vehicle_id] = true
            trip
          end
        end
      else
        unique_trips = [@itinerary.trips.find_by(tenant_vehicle_id: @service_level.id)]
      end
      @schedules = unique_trips.map do |trip|
        attributes = {
          origin_hub_id: @origin_hub.id,
          destination_hub_id: @destination_hub.id,
          origin_hub_name: @origin_hub.name,
          destination_hub_name: @destination_hub.name,
          mode_of_transport: @itinerary.mode_of_transport,
          eta: DateTime.now + 20.days,
          etd: DateTime.now + 10.days,
          closing_date: DateTime.now + 5.days,
          vehicle_name: trip.tenant_vehicle.name,
          trip_id: trip.id
        }
        Schedule.new(attributes.merge(id: SecureRandom.uuid))
      end
    end

    def cargo_unit_const
      @shipment_data[:load_type].camelize.constantize
    end

    def calc_local_charges
      cargo_units = @cargo_units
      if @shipment_data[:has_pre_carriage] || @shipment_data[:export] || @origin_hub.mandatory_charge.export_charges
        local_charges_data = determine_local_charges(
          @origin_hub,
          @shipment_data[:load_type],
          cargo_units,
          'export',
          @itinerary.mode_of_transport,
          @schedule.trip.tenant_vehicle_id,
          @destination_hub.id,
          @user
        )

        unless local_charges_data.empty?
          create_charges_from_fees_data!(local_charges_data, ChargeCategory.from_code('export'))
        end
      end

      if @shipment_data[:has_on_carriage] || @shipment_data[:import] || @destination_hub.mandatory_charge.import_charges
        local_charges_data = determine_local_charges(
          @destination_hub,
          @shipment_data[:load_type],
          cargo_units,
          'import',
          @itinerary.mode_of_transport,
          @schedule.trip.tenant_vehicle_id,
          @origin_hub.id,
          @user
        )

        unless local_charges_data.empty?
          create_charges_from_fees_data!(local_charges_data, ChargeCategory.from_code('import'))
        end
      end
    end

    def create_trucking_charges
      @trucking_data.each do |carriage, data|
        charge_category = ChargeCategory.find_or_create_by(
          name: "Trucking #{carriage.capitalize}-Carriage", code: "trucking_#{carriage}"
        )

        parent_charge = create_parent_charge(charge_category)

        hub = @schedule.hub_for_carriage(carriage)
        hub_data = data[hub.id]

        hub_data[:trucking_charge_data].each do |cargo_class, trucking_charges|
          children_charge_category = ChargeCategory.from_code("trucking_#{cargo_class}")

          create_charges_from_fees_data!(
            trucking_charges, children_charge_category, charge_category, parent_charge
          )
        end
        parent_charge.update_quote_price!(@itinerary.tenant_id)
      end
    end

    def calc_cargo_charges
      total_units = @cargo_units.reduce(0) do |sum, cargo_unit|
        sum + cargo_unit.try(:quantity).to_i
      end

      charge_category = ChargeCategory.from_code('cargo')
      parent_charge = create_parent_charge(charge_category)
      cargo_unit_array = @cargo_units

      if @user.tenant.scope['consolidate_cargo'] && cargo_unit_array.first.is_a?(CargoItem)
        cargo_unit_array = consolidate_cargo(cargo_unit_array, @itinerary.mode_of_transport)
      end
      cargo_unit_array.each do |cargo_unit|
        charge_result = send("determine_#{@shipment_data[:load_type]}_price",
                             cargo_unit,
                             @schedule,
                             @user,
                             total_units,
                             @schedule.etd,
                             @itinerary.mode_of_transport)
        next if charge_result.nil?

        cargo_unit_model = cargo_unit.class.to_s == 'Hash' ? 'CargoItem' : cargo_unit.class.to_s

        children_charge_category = ChargeCategory.find_or_create_by(
          name:          cargo_unit_model.humanize,
          code:          cargo_unit_model.underscore,
          cargo_unit_id: cargo_unit[:id]
        )

        create_charges_from_fees_data!(charge_result, children_charge_category, charge_category, parent_charge)
      end

      parent_charge.update_quote_price!(@itinerary.tenant_id)
    end

    def create_parent_charge(children_charge_category)
      Charge.create(
        children_charge_category: children_charge_category,
        charge_category:          ChargeCategory.grand_total,

        parent:                   @grand_total_charge,
        price:                    Price.create(currency: @user.currency)
      )
    end

    def create_charges_from_fees_data!(
      fees_data,
      children_charge_category,
      charge_category = ChargeCategory.grand_total,
      parent = @grand_total_charge
    )
      parent_charge = Charge.create(
        children_charge_category: children_charge_category,
        charge_category:          charge_category,

        parent:                   parent,
        price:                    Price.create(fees_data['total'] || fees_data[:total])
      )

      fees_data.each do |code, charge|
        next if code.to_s == 'total' || charge.empty?

        Charge.create(
          children_charge_category: ChargeCategory.from_code(code),
          charge_category:          children_charge_category,

          parent:                   parent_charge,
          price:                    Price.create(charge)
        )
      end
    end

    def destroy_previous_charge_breakdown
      ChargeBreakdown.find_by(shipment: @shipment_data, trip_id: @schedule.trip_id)&.destroy
    end

    def consolidate_cargo(cargo_array, mot)
      cargo = {
        id:                'ids',
        dimension_x:       0,
        dimension_y:       0,
        dimension_z:       0,
        volume:            0,
        payload_in_kg:     0,
        cargo_class:       '',
        chargeable_weight: 0,
        num_of_items:      0
      }
      cargo_array.each do |cargo_unit|
        cargo[:id] += "-#{cargo_unit.id}"
        cargo[:dimension_x] += (cargo_unit.dimension_x * cargo_unit.quantity)
        cargo[:dimension_y] += (cargo_unit.dimension_y * cargo_unit.quantity)
        cargo[:dimension_z] += (cargo_unit.dimension_z * cargo_unit.quantity)
        cargo[:volume] += (cargo_unit.volume * cargo_unit.quantity)
        cargo[:payload_in_kg] += (cargo_unit.payload_in_kg * cargo_unit.quantity)
        cargo[:cargo_class] = cargo_unit.cargo_class
        cargo[:chargeable_weight] += (cargo_unit.calc_chargeable_weight(mot) * cargo_unit.quantity)
        cargo[:num_of_items] += cargo_unit.quantity
      end
      [cargo]
    end
  end
end
