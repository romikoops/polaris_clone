# frozen_string_literal: true

module OfferCalculator
  module Service
    class ChargeCalculator < Base # rubocop:disable Metrics/ClassLength
      def initialize(args = {})
        @data = args.fetch(:data)
        @trucking_data = args.fetch(:trucking_data)
        @schedules = @data.fetch(:schedules)
        @schedule = @data.fetch(:schedules)&.first
        @user = args.fetch(:user)
        @sandbox = args.fetch(:sandbox)
        @shipment = args.fetch(:shipment)
        @metadata_list = args.fetch(:metadata_list, [])
        @pricing_tools = OfferCalculator::PricingTools.new(
          shipment: @shipment,
          user: @user,
          sandbox: @sandbox,
          metadata: @metadata_list
        )
        super(shipment: @shipment, sandbox: @sandbox)
      end

      def perform
        return [{ error: OfferCalculator::Calculator::InvalidTruckingMatch }] unless trucking_valid_for_schedule

        periods = local_charge_periods
        return [{ error: OfferCalculator::Calculator::InvalidLocalCharges }] if periods.values.compact.any?(&:empty?)

        charges_by_period = sort_by_local_charge_periods(periods)
        charges_by_period.values
                         .map { |charge_obj| handle_perform_loop(charge_obj: charge_obj, periods: periods) }.compact
      end

      private

      def handle_perform_loop(charge_obj:, periods:)
        destroy_previous_charge_breakdown(charge_obj[:schedules].first.trip_id)
        create_charge_variables(charge_obj: charge_obj, periods: periods)

        local_charge_result = calc_local_charges(charge_obj)
        create_trucking_charges

        cargo_result = calc_cargo_charges
        if cargo_result.blank?
          { error: OfferCalculator::Calculator::InvalidFreightResult }
        elsif local_charge_result.blank?
          { error: OfferCalculator::Calculator::InvalidLocalChargeResult }
        else
          @grand_total_charge.update_price!
          @grand_total_charge.save

          { total: @grand_total_charge, schedules: charge_obj[:schedules], metadata: @metadata }
        end
      end

      def create_charge_variables(charge_obj:, periods:)
        @charge_breakdown = Legacy::ChargeBreakdown.create!(
          shipment: @shipment,
          trip_id: charge_obj[:schedules].first.trip_id,
          sandbox: @sandbox,
          valid_until: valid_until(periods)
        )
        @grand_total_charge = Legacy::Charge.create(
          children_charge_category: Legacy::ChargeCategory.grand_total,
          charge_category: Legacy::ChargeCategory.base_node,
          charge_breakdown: @charge_breakdown,
          price: Legacy::Price.create(currency: @shipment.user.currency),
          sandbox: @sandbox
        )
        @metadata = Pricings::Metadatum.create(
          tenant: Tenants::Tenant.find_by(legacy_id: @user.tenant_id),
          charge_breakdown_id: @charge_breakdown.id
        )
      end

      def dynamic_mandatory_charge_check(schedule:)
        export = schedule.origin_hub.local_charges
                         .exists?(direction: 'export', counterpart_hub_id: schedule.destination_hub_id) ||
                 schedule.origin_hub.local_charges
                         .exists?(direction: 'export', counterpart_hub_id: nil)
        import = schedule.destination_hub.local_charges
                         .exists?(direction: 'export', counterpart_hub_id: schedule.origin_hub_id) ||
                 schedule.destination_hub.local_charges
                         .exists?(direction: 'export', counterpart_hub_id: nil)

        {
          export: export && schedule.origin_hub.mandatory_charge.export_charges,
          import: import && schedule.destination_hub.mandatory_charge.import_charges
        }
      end

      def sort_by_local_charge_periods(periods)
        export_periods = periods[:export] || {}
        import_periods = periods[:import] || {}

        schedules_by_charges(import_periods: import_periods, export_periods: export_periods)
          .compact
          .group_by { |sbc| sbc.slice(:import_key, :export_key) }
          .each_with_object({}) do |(charge_keys, values), hash|
          inner_hash = {
            schedules: values.map { |v| v[:schedule] },
            export: export_periods[charge_keys[:export_key]],
            import: import_periods[charge_keys[:import_key]],
            effective_date: [
              charge_keys.dig(:import_key, :effective_date), charge_keys.dig(:export_key, :effective_date)
            ].compact.max,
            expiration_date: [
              charge_keys.dig(:import_key, :expiration_date), charge_keys.dig(:export_key, :expiration_date)
            ].compact.min
          }
          hash[charge_keys] = inner_hash
        end
      end

      def schedules_by_charges(import_periods:, export_periods:)
        validity = OfferCalculator::ValidityService.new(
          logic: @scope.fetch('validity_logic'),
          direction: '',
          booking_date: @shipment.desired_start_date,
          schedules: []
        )
        filtered_schedules = @schedules.map do |schedule|
          schedule_equality(
            schedule: schedule,
            validity: validity,
            import_periods: import_periods,
            export_periods: export_periods
          )
        end
        filtered_schedules.compact
      end

      def schedule_equality(schedule:, validity:, import_periods:, export_periods:)
        check = dynamic_mandatory_charge_check(schedule: schedule)
        sched_validable_date = schedule_validity_date(validity: validity, schedule: schedule)
        export_key = period_key_from_schedule(periods: export_periods, target_date: sched_validable_date)
        import_key = period_key_from_schedule(periods: import_periods, target_date: sched_validable_date)
        return if schedule_is_invalid?(import_key: import_key, export_key: export_key, check: check)

        {
          schedule: schedule,
          export_key: export_key,
          import_key: import_key
        }
      end

      def schedule_is_invalid?(import_key:, export_key:, check:) # rubocop:disable Metrics/CyclomaticComplexity
        return true if export_key.nil? && (@shipment.has_pre_carriage || check[:export])
        return true if import_key.nil? && (@shipment.has_on_carriage || check[:import])
      end

      def schedule_validity_date(validity:, schedule:)
        validity.parse_schedule(schedule: schedule, direction: @shipment.direction)
        validity.start_date
      end

      def period_key_from_schedule(periods:, target_date:)
        periods.keys.find do |exk|
          target_date < exk[:expiration_date] && target_date > exk[:effective_date]
        end
      end

      def local_charge_periods
        %w[import export].each_with_object({}) do |direction, hash|
          if direction == 'export'
            next unless @shipment.has_pre_carriage || @schedule.origin_hub.mandatory_charge.export_charges
          else
            next unless @shipment.has_on_carriage || @schedule.destination_hub.mandatory_charge.import_charges
          end
          local_charge_charge_and_metadata(result: hash, direction: direction)
        end
      end

      def local_charge_charge_and_metadata(result:, direction:)
        local_charges_data, local_charge_metadata = @pricing_tools.determine_local_charges(
          @schedules,
          cargo_units,
          direction,
          @user
        )
        result[direction.to_sym] = local_charges_data if local_charges_data.present?

        @metadata_list |= local_charge_metadata if local_charge_metadata.present?
        result
      end

      def cargo_units
        if @shipment.aggregated_cargo
          [@shipment.aggregated_cargo]
        else
          @shipment.cargo_units
        end
      end

      def calc_local_charges(charge_obj)
        pre_carriage = nil
        on_carriage = nil
        %i[import export].each do |direction|
          next if charge_obj[direction].blank?

          charge_category, parent_charge = parent_charge_and_category(code: direction)
          charge_obj[direction].each do |charge|
            next if charge.except('total').empty?

            local_charge_creation_block(
              charge: charge,
              parent_charge: parent_charge,
              charge_category: charge_category
            )
          end

          return nil if parent_charge.children.empty?

          parent_charge.update_price!
          if direction == :export
            pre_carriage = parent_charge
          else
            on_carriage = parent_charge
          end
        end

        { pre_carriage: pre_carriage, on_carriage: on_carriage }
      end

      def cargo_unit_model(key:)
        if key == 'shipment'
          'Shipment'
        elsif @shipment.lcl?
          'CargoItem'
        else
          'Container'
        end
      end

      def local_charge_creation_block(charge:, parent_charge:, charge_category:)
        cargo_unit_model = cargo_unit_model(key: charge['key'])

        children_charge_category = Legacy::ChargeCategory.find_or_create_by!(
          name: cargo_unit_model.humanize,
          code: cargo_unit_model.underscore.downcase,
          tenant_id: @shipment.tenant_id,
          cargo_unit_id: cargo_unit_id(key: charge['key']),
          sandbox_id: @sandbox&.id
        )
        create_charges_and_metadata_from_fees_data!(charge.except('key'),
                                                    children_charge_category,
                                                    charge_category,
                                                    parent_charge)
      end

      def parent_charge_and_category(code:)
        charge_category = Legacy::ChargeCategory.from_code(code: code.to_s,
                                                           tenant_id: @user.tenant_id,
                                                           sandbox: @sandbox)
        parent_charge = create_parent_charge(charge_category)

        [charge_category, parent_charge]
      end

      def cargo_unit_id(key:)
        %w[shipment lcl].include?(key) ? nil : key
      end

      def create_trucking_charges
        @trucking_data.each do |carriage, data|
          charge_category = Legacy::ChargeCategory.from_code(
            code: "trucking_#{carriage}",
            tenant_id: @user.tenant_id,
            sandbox: @sandbox
          )

          parent_charge = create_parent_charge(charge_category)

          hub = @schedule.hub_for_carriage(carriage)
          hub_data = data[hub.id]
          next if hub_data.nil?

          hub_data[:trucking_charge_data].each do |cargo_class, trucking_charges|
            children_charge_category = Legacy::ChargeCategory.from_code(
              code: "trucking_#{cargo_class}",
              tenant_id: @user.tenant_id,
              sandbox: @sandbox
            )

            create_charges_and_metadata_from_fees_data!(
              trucking_charges, children_charge_category, charge_category, parent_charge
            )
          end
          parent_charge.update_price!
        end
      end

      def aggregated_cargo?
        @shipment.aggregated_cargo.present?
      end

      def cargo_unit_array_for_freight
        cargo_unit_array = aggregated_cargo? ? [@shipment.aggregated_cargo] : @shipment.cargo_units

        if @scope.dig('consolidation', 'cargo', 'backend') && cargo_unit_array.first.is_a?(Legacy::CargoItem)
          cargo_unit_array = consolidate_cargo(cargo_unit_array, @schedule.mode_of_transport)
        end
        cargo_unit_array
      end

      def calc_cargo_charges
        charge_category, parent_charge = parent_charge_and_category(code: 'cargo')
        cargo_unit_array_for_freight.each do |cargo_unit|
          charge_result, pricing_metadata_list = cargo_unit_charge_result(cargo_unit: cargo_unit)
          @metadata_list |= pricing_metadata_list if pricing_metadata_list.present?

          next if charge_result.nil?

          cargo_unit_model, cargo_unit_id = cargo_unit_model_and_id(cargo_unit: cargo_unit)

          children_charge_category = build_children_charge_category(
            cargo_unit_model: cargo_unit_model,
            cargo_unit_id: cargo_unit_id
          )

          create_charges_and_metadata_from_fees_data!(
            charge_result, children_charge_category, charge_category, parent_charge
          )
        end
        return nil if parent_charge.children.empty?

        parent_charge.update_price!
      end

      def cargo_unit_model_and_id(cargo_unit:)
        cunit_class = cargo_unit.class.to_s
        cargo_unit_model = cunit_class == 'Hash' || aggregated_cargo? ? 'CargoItem' : cunit_class.gsub('Legacy::', '')
        cargo_unit_id = cunit_class == 'Hash' ? nil : cargo_unit[:id]

        [cargo_unit_model, cargo_unit_id]
      end

      def cargo_unit_charge_result(cargo_unit:)
        cargo_class = cargo_unit.is_a?(Legacy::Container) ? cargo_unit.cargo_class : 'lcl'
        if @scope['base_pricing']
          Pricings::Calculator.new(
            cargo: cargo_unit,
            pricing: @data.dig(:pricings_by_cargo_class, cargo_class),
            user: @user,
            mode_of_transport: @schedule.mode_of_transport,
            date: @shipment.planned_pickup_date,
            metadata: @metadata_list
          ).perform
        else
          @pricing_tools.determine_cargo_freight_price(
            cargo: cargo_unit,
            pricing: @data.dig(:pricings_by_cargo_class, cargo_class, 'data'),
            user: @user,
            mode_of_transport: @schedule.mode_of_transport
          )
        end
      end

      def build_children_charge_category(cargo_unit_model:, cargo_unit_id:)
        Legacy::ChargeCategory.find_or_create_by!(
          name: cargo_unit_model.humanize,
          code: cargo_unit_model.underscore.downcase,
          tenant_id: @shipment.tenant_id,
          cargo_unit_id: cargo_unit_id,
          sandbox_id: @sandbox&.id
        )
      end

      def create_parent_charge(children_charge_category)
        Legacy::Charge.create(
          children_charge_category: children_charge_category,
          charge_category: Legacy::ChargeCategory.grand_total,
          charge_breakdown: @charge_breakdown,
          parent: @grand_total_charge,
          price: Legacy::Price.create(currency: @shipment.user.currency),
          sandbox: @sandbox
        )
      end

      def create_charges_and_metadata_from_fees_data!(
        fees_data,
        children_charge_category,
        charge_category = Legacy::ChargeCategory.grand_total,
        parent = @grand_total_charge
      )
        parent_charge = Legacy::Charge.create(
          children_charge_category: children_charge_category,
          charge_category: charge_category,
          charge_breakdown: @charge_breakdown,
          parent: parent,
          price: Legacy::Price.create(fees_data['total'] || fees_data[:total]),
          sandbox: @sandbox
        )

        fees_data.except('total', 'metadata_id').each do |code, charge_object|
          next if charge_object.empty?

          create_charges_block(
            children_charge_category: children_charge_category,
            parent_charge: parent_charge,
            charge_object: charge_object,
            code: code,
            fees_data: fees_data
          )
        end
      end

      def create_charges_block(
        children_charge_category:,
        parent_charge:,
        charge_object:,
        code:,
        fees_data:
      )
        charge = Legacy::Charge.create(
          children_charge_category: Legacy::ChargeCategory.from_code(code: code, tenant_id: @user.tenant_id),
          charge_category: children_charge_category,
          charge_breakdown: @charge_breakdown,
          parent: parent_charge,
          price: Legacy::Price.create(charge_object),
          sandbox: @sandbox
        )

        target_metadata = @metadata_list.find { |meta| meta[:metadata_id] == fees_data['metadata_id'] }
        return if target_metadata.blank?

        handle_metadata_from_fees(
          charge: charge,
          target_metadata: target_metadata,
          code: code,
          children_charge_category: children_charge_category
        )
      end

      def handle_metadata_from_fees(charge:, target_metadata:, code:, children_charge_category:)
        target_fee, target_charge_category = if target_metadata[:fees].key?(code.to_sym)
                                               [
                                                 target_metadata.dig(:fees, code.to_sym),
                                                 charge.children_charge_category
                                               ]
                                             else
                                               [
                                                 target_metadata.dig(:fees, children_charge_category.code.to_sym),
                                                 children_charge_category
                                               ]
                                             end
        return if target_fee.blank?

        create_metadata_from_charges(
          charge: charge,
          fee_data: target_fee,
          charge_category: target_charge_category
        )
      end

      def cargo_metadata(cargo_id)
        return {} if cargo_id.blank?

        if @shipment.aggregated_cargo.present?
          {
            cargo_class: 'lcl',
            id: cargo_id,
            class: 'Legacy::AggregatedCargo'
          }
        else
          cargo = @shipment.cargo_units.find(cargo_id)
          {
            cargo_class: cargo.cargo_class,
            id: cargo.id,
            class: cargo.class.to_s
          }
        end
      end

      def create_metadata_from_charges(charge:, fee_data:, charge_category: nil)
        charge_category ||= charge.children_charge_category
        cargo_id = charge.charge_category.cargo_unit_id
        cargo_info = cargo_metadata(cargo_id)
        fee_data[:breakdowns].each_with_index do |breakdown, i|
          pricing_breakdown = Pricings::Breakdown.new(
            metadatum: @metadata,
            charge_id: charge.id,
            order: i,
            data: breakdown[:adjusted_rate],
            charge_category_id: charge_category.id,
            rate_origin: fee_data[:metadata],
            cargo_unit_type: cargo_info[:class],
            cargo_unit_id: cargo_info[:id],
            cargo_class: cargo_info[:cargo_class]
          )
          if breakdown[:operator].present?
            pricing_breakdown.assign_attributes(
              source_id: breakdown[:source_id],
              source_type: breakdown[:source_type],
              target_type: breakdown[:margin_target_type],
              target_id: breakdown[:margin_target_id]
            )
          end

          pricing_breakdown.save
        end
      end

      def destroy_previous_charge_breakdown(trip_id)
        Legacy::ChargeBreakdown.find_by(shipment: @shipment, trip_id: trip_id, sandbox: @sandbox).try(:destroy)
      end

      def consolidate_cargo(cargo_array, mot)
        cargo = cargo_array.each_with_object(Hash.new { |h, k| h[k] = 0 }) do |cargo_unit, consolidated|
          merge_cargo_into_consolidated(consolidated: consolidated, cargo_unit: cargo_unit)
        end
        cargo[:id] = 'ids-' + cargo_array.pluck(:id).join('-')
        cargo[:chargeable_weight] =
          Legacy::CargoItem.calc_chargeable_weight_from_values(cargo[:volume], cargo[:payload_in_kg], mot)

        [cargo]
      end

      def merge_cargo_into_consolidated(consolidated:, cargo_unit:)
        consolidated[:dimension_x] += (cargo_unit.dimension_x * cargo_unit.quantity)
        consolidated[:dimension_y] += (cargo_unit.dimension_y * cargo_unit.quantity)
        consolidated[:dimension_z] += (cargo_unit.dimension_z * cargo_unit.quantity)
        consolidated[:volume] += (cargo_unit.volume * cargo_unit.quantity)
        consolidated[:payload_in_kg] += (cargo_unit.payload_in_kg * cargo_unit.quantity)
        consolidated[:cargo_class] = cargo_unit.cargo_class
        consolidated[:num_of_items] += cargo_unit.quantity
        consolidated
      end

      def trucking_valid_for_schedule
        results = []
        results << @trucking_data.dig('pre', @schedule.origin_hub_id).present? if @shipment.has_pre_carriage?

        results << @trucking_data.dig('on', @schedule.destination_hub_id).present? if @shipment.has_on_carriage?

        results.all?(true)
      end

      def valid_until(periods)
        export_date_limit = periods[:export].keys.pluck('expiration_date').min if periods[:export].present?
        freight_date_limit = @data[:pricings_by_cargo_class].values.pluck('expiration_date').min

        [export_date_limit, freight_date_limit].compact.min.beginning_of_day
      end
    end
  end
end
