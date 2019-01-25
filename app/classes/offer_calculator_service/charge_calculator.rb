# frozen_string_literal: true

module OfferCalculatorService
  class ChargeCalculator < Base
    include CurrencyTools
    include PricingTools

    def initialize(args = {})
      @trucking_data = args[:trucking_data]
      @schedule      = args[:data][:schedules].first
      @user          = args[:user]
      @data = args[:data]
      super(args[:shipment])
    end

    def perform
      destroy_previous_charge_breakdown

      @charge_breakdown = ChargeBreakdown.create!(shipment: @shipment, trip_id: @schedule.trip_id)
      @grand_total_charge = Charge.create(
        children_charge_category: ChargeCategory.grand_total,
        charge_category:          ChargeCategory.base_node,
        charge_breakdown:         @charge_breakdown,
        price:                    Price.create(currency: @shipment.user.currency)
      )

      local_charge_result = calc_local_charges
      create_trucking_charges
      cargo_result = calc_cargo_charges
      return nil if cargo_result.nil? || local_charge_result.nil?

      @grand_total_charge.update_price!
      @grand_total_charge.save

      @grand_total_charge
    end

    private

    def calc_local_charges
      cargo_units =
        if @shipment.aggregated_cargo
          [@shipment.aggregated_cargo]
        else
          @shipment.cargo_units
        end

      if @shipment.has_pre_carriage || @schedule.origin_hub.mandatory_charge.export_charges
        local_charges_data = determine_local_charges(
          @schedule.origin_hub,
          @shipment.load_type,
          cargo_units,
          'export',
          @schedule.mode_of_transport,
          @schedule.trip.tenant_vehicle.id,
          @schedule.destination_hub_id,
          @user
        )

        return nil if local_charges_data.except('total').empty?

        pre_carriage = create_charges_from_fees_data!(
          local_charges_data,
          ChargeCategory.from_code('export', @user.tenant_id)
        )
      end

      if @shipment.has_on_carriage || @schedule.destination_hub.mandatory_charge.import_charges
        local_charges_data = determine_local_charges(
          @schedule.destination_hub,
          @shipment.load_type,
          cargo_units,
          'import',
          @schedule.mode_of_transport,
          @schedule.trip.tenant_vehicle.id,
          @schedule.origin_hub_id,
          @user
        )

        return nil if local_charges_data.except('total').empty?

        on_carriage = create_charges_from_fees_data!(
          local_charges_data,
          ChargeCategory.from_code('import', @user.tenant_id)
        )
      end

      { pre_carriage: pre_carriage, on_carriage: on_carriage }
    end

    def create_trucking_charges
      @trucking_data.each do |carriage, data|
        charge_category = ChargeCategory.from_code("trucking_#{carriage}", @user.tenant_id)

        parent_charge = create_parent_charge(charge_category)

        hub = @schedule.hub_for_carriage(carriage)
        hub_data = data[hub.id]

        hub_data[:trucking_charge_data].each do |cargo_class, trucking_charges|
          children_charge_category = ChargeCategory.from_code("trucking_#{cargo_class}", @user.tenant_id)

          create_charges_from_fees_data!(
            trucking_charges, children_charge_category, charge_category, parent_charge
          )
        end
        parent_charge.update_price!
      end
    end

    def calc_cargo_charges
      total_units = @shipment.cargo_units.reduce(0) do |sum, cargo_unit|
        sum + cargo_unit.try(:quantity).to_i
      end

      charge_category = ChargeCategory.from_code('cargo', @user.tenant_id)
      parent_charge = create_parent_charge(charge_category)
      isAggCargo = !@shipment.aggregated_cargo.nil?
      cargo_unit_array = isAggCargo ? [@shipment.aggregated_cargo] : @shipment.cargo_units

      if @user.tenant.scope.dig('consolidation', 'cargo', 'backend') && cargo_unit_array.first.is_a?(CargoItem)
        cargo_unit_array = consolidate_cargo(cargo_unit_array, @schedule.mode_of_transport)
      end
      cargo_unit_array.each do |cargo_unit|
        cargo_class = isAggCargo ? 'lcl' : cargo_unit[:cargo_class]
        charge_result = send("determine_#{@shipment.load_type}_price",
                             cargo_unit,
                             @data[:pricing_ids][cargo_class],
                             @user,
                             total_units,
                             @shipment.planned_pickup_date,
                             @schedule.mode_of_transport)

        next if charge_result.nil?

        cargo_unit_model = cargo_unit.class.to_s == 'Hash' || isAggCargo ? 'CargoItem' : cargo_unit.class.to_s

        children_charge_category = ChargeCategory.find_or_create_by(
          name:          cargo_unit_model.humanize,
          code:          cargo_unit_model.underscore.downcase,
          cargo_unit_id: cargo_unit[:id]
        )

        create_charges_from_fees_data!(charge_result, children_charge_category, charge_category, parent_charge)
      end
      return nil if parent_charge.children.empty?

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
      charge_category = ChargeCategory.grand_total,
      parent = @grand_total_charge
    )
      parent_charge = Charge.create(
        children_charge_category: children_charge_category,
        charge_category:          charge_category,
        charge_breakdown:         @charge_breakdown,
        parent:                   parent,
        price:                    Price.create(fees_data['total'] || fees_data[:total])
      )

      fees_data.each do |code, charge|
        next if code.to_s == 'total' || charge.empty?

        Charge.create(
          children_charge_category: ChargeCategory.from_code(code, @user.tenant_id),
          charge_category:          children_charge_category,
          charge_breakdown:         @charge_breakdown,
          parent:                   parent_charge,
          price:                    Price.create(charge)
        )
      end
    end

    def destroy_previous_charge_breakdown
      ChargeBreakdown.find_by(shipment: @shipment, trip_id: @schedule.trip_id).try(:destroy)
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
        cargo[:num_of_items] += cargo_unit.quantity
      end
      cargo[:chargeable_weight] =
        CargoItem.calc_chargeable_weight_from_values(cargo[:volume], cargo[:payload_in_kg], mot)

      [cargo]
    end
  end
end
