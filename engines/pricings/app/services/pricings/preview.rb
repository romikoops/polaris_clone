# frozen_string_literal: true

module Pricings
  class Preview # rubocop:disable Metrics/ClassLength
    attr_accessor :itinerary, :tenant_vehicle_id, :cargo_class, :target, :date, :organization

    def initialize(params:, target:, organization: nil, tenant_vehicle_id: nil, date: Date.today + 5.days)
      @params = params
      @target = target
      @organization = organization
      @scope = OrganizationManager::ScopeService.new(target: target, organization: organization).fetch
      @local_charges = { origin: [], destination: [] }
      @cargo_class = params[:selectedCargoClass]
      @load_type = params[:selectedCargoClass] == 'lcl' ? 'cargo_item' : 'container'
      @hierarchy = OrganizationManager::HierarchyService.new(target: target, organization: organization).fetch
      @pricings_to_return = []
      @date = date
      @truckings = {}
      @manipulated_pricings = []
      @manipulated_local_charges = []
      @manipulated_truckings = []
      @metadata_pricings = []
      @metadata_local_charges = []
      @metadata_truckings = []
    end

    def perform
      handle_trucking
      determine_itineraries
      prepare_trips
      determine_service_levels
      determine_local_charges
      manipulate_pricings
      manipulate_local_charges
      manipulate_truckings
      determine_route_combinations

      @route_results.compact
    end

    def determine_route_combinations
      @route_results = @manipulated_pricings.map do |pricing|
        origin_hub, destination_hub = ::Legacy::Itinerary.find(pricing[:itinerary_id]).stops.map(&:hub)
        pre_carriage = @manipulated_truckings.find { |trucking| trucking[:hub_id] == origin_hub.id }
        on_carriage = @manipulated_truckings.find { |trucking| trucking[:hub_id] == destination_hub.id }
        origin_charges_mandatory = origin_hub.mandatory_charge&.export_charges || pre_carriage.present?
        destination_charges_mandatory = destination_hub.mandatory_charge&.import_charges || on_carriage.present?
        origin_local_charge = @manipulated_local_charges.find do |lc|
          lc[:hub_id] == origin_hub.id && lc[:direction] == 'export' && lc[:tenant_vehicle_id] == pricing[:tenant_vehicle_id]
        end
        destination_local_charge = @manipulated_local_charges.find do |lc|
          lc[:hub_id] == destination_hub.id && lc[:direction] == 'import' && lc[:tenant_vehicle_id] == pricing[:tenant_vehicle_id]
        end

        next if origin_charges_mandatory && origin_local_charge.nil?
        next if destination_charges_mandatory && destination_local_charge.nil?

        result = {
          freight: build_breakdowns(target: pricing, type: 'pricing')
        }
        if origin_local_charge.present?
          result[:export] = build_breakdowns(target: origin_local_charge, type: 'local_charge')
        end
        if destination_local_charge.present?
          result[:import] = build_breakdowns(target: destination_local_charge, type: 'local_charge')
        end
        result[:trucking_pre] = build_breakdowns(target: pre_carriage, type: 'trucking') if pre_carriage.present?
        result[:trucking_on] = build_breakdowns(target: on_carriage, type: 'trucking') if on_carriage.present?

        result
      end
    end

    def build_breakdowns(target:, type:)
      metadata = case type
                 when 'pricing'
                   @metadata_pricings
                 when 'local_charge'
                   @metadata_local_charges
                 when 'trucking'
                   @metadata_truckings
                 end

      target_service_level = tenant_vehicles.find_by(id: target[:tenant_vehicle_id])
      target_metadata = metadata.find { |md| md[:metadata_id] == target[:metadata_id] }
      breakdowns = {}

      breakdowns[:fees] = build_breakdown_response(metadata: target_metadata)

      breakdowns[:service_level] =
        if target_service_level.present?
          target_service_level.full_name
        else
          Trucking::Courier.find_by(id: target[:courier_id])&.name
        end

      breakdowns
    end

    def manipulate_breakdown(breakdown:)
      adjusted_breakdown = breakdown.dup
      adjusted_breakdown[:data] = adjusted_breakdown.delete(:adjusted_rate)
      adjusted_breakdown[:target_name] = adjusted_breakdown.delete(:margin_target_name)
      adjusted_breakdown[:target_id] = adjusted_breakdown.delete(:margin_target_id)
      adjusted_breakdown[:target_type] = adjusted_breakdown.delete(:margin_target_type)
      adjusted_breakdown[:url_id] =
        if breakdown[:margin_target_type] == 'Organizations::User'
          Organizations::User.find(breakdown[:margin_target_id]).id
        else
          breakdown[:margin_target_id]
        end

      adjusted_breakdown
    end

    def build_breakdown_response(metadata:)
      metadata[:fees].each_with_object({}) do |(fee_key, data), hash|
        adjusted_breakdowns = data[:breakdowns].map { |breakdown| manipulate_breakdown(breakdown: breakdown) }
        margin_breakdowns = adjusted_breakdowns.reject { |breakdown| breakdown[:operator] == '+' }
        flat_breakdowns = adjusted_breakdowns.select { |breakdown| breakdown[:operator] == '+' }
        original = adjusted_breakdowns.find { |breakdown| breakdown[:source_id].blank? }
        hash[fee_key] = {
          original: original[:data],
          margins: margin_breakdowns.reject { |breakdown| breakdown == original },
          flatMargins: flat_breakdowns,
          final: margin_breakdowns.last[:data],
          rate_origin: original[:data].present? ? fee_origins[original[:id]][fee_key] : original[:metadata]
        }
        hash
      end
    end

    def handle_trucking
      args = {
        load_type: @load_type,
        organization_id: @organization.id,
        truck_type: @cargo_class == 'lcl' ? 'default' : 'chassis',
        cargo_classes: [@cargo_class],
        sandbox: @sandbox,
        order_by: 'group_id'
      }
      @params.slice(:selectedOriginTrucking, :selectedDestinationTrucking).each do |key, target|
        next if target.empty?

        carriage = key.to_sym == :selectedOriginTrucking ? 'pre' : 'on'
        adjusted_args = args.merge(
          address: ::Legacy::Address.new(latitude: target[:lat], longitude: target[:lng]).reverse_geocode,
          carriage: carriage
        )
        results = Trucking::Queries::Availability.new(adjusted_args).perform
        next if results.empty?

        hub_truckings = []
        grouped_results = results.group_by(&:hub_id)
        trucking_group_ids = group_ids.dup.unshift(nil)
        trucking_group_ids.each do |group_id|
          grouped_results.each do |_hub_id, truckings_by_cargo_class|
            designated_trucking = truckings_by_cargo_class.find { |trp| trp.user_id.nil? && group_id == trp.group_id }
            hub_truckings << designated_trucking if designated_trucking.present?
          end
        end

        @truckings[carriage] = hub_truckings
      end
    end

    def determine_itineraries
      origin_stops = ::Legacy::Stop.where(hub_id: origin_hub_ids, index: 0)
      destination_stops = ::Legacy::Stop.where(hub_id: destination_hub_ids, index: 1)
      itinerary_ids = origin_stops.select { |os| destination_stops.any? { |ds| ds.itinerary_id == os.itinerary_id } }.map(&:itinerary_id)
      @itineraries = ::Legacy::Itinerary.where(id: itinerary_ids)
    end

    def tenant_vehicles
      @tenant_vehicles ||= ::Legacy::TenantVehicle.where(id: pricings.pluck(:tenant_vehicle_id))
    end

    def fee_origins
      @fee_origins ||= Pricings::Fee.where(pricing_id: pricings.ids).each_with_object(Hash.new { |h, k| h[k] = {} }) do |fee, hash|
        hash[fee.pricing_id][fee.fee_code] = fee.metadata if fee.metadata.present?
      end
    end

    def determine_service_levels
      ::Legacy::TenantVehicle.where(id: pricings.pluck(:tenant_vehicle_id))
    end

    def determine_local_charges
      cargo_local_charges = ::Legacy::LocalCharge.where(load_type: @cargo_class)
      @local_charges[:origin] = cargo_local_charges.where(
        hub_id: origin_hub_ids,
        group_id: group_ids,
        direction: 'export'
      )
      @local_charges[:destination] = cargo_local_charges.where(
        hub_id: destination_hub_ids,
        direction: 'import',
        group_id: group_ids
      )
      if @local_charges[:origin].empty?
        @local_charges[:origin] = cargo_local_charges.where(
          hub_id: origin_hub_ids,
          group_id: nil,
          direction: 'export'
        )
      end
      return if @local_charges[:destination].present?

      @local_charges[:destination] = cargo_local_charges.where(
        hub_id: destination_hub_ids,
        group_id: nil,
        direction: 'import'
      )
    end

    def manipulate_pricings
      pricings.each do |pricing|
        manipulated, metadata = Pricings::Manipulator.new(
          type: :freight_margin,
          target: @target,
          organization: @organization,
          args: {
            schedules: default_schedules(tenant_vehicle_id: pricing.tenant_vehicle_id),
            pricing: pricing,
            cargo_class_count: 1,
            sandbox: @sandbox
          }
        ).perform
        @manipulated_pricings |= manipulated
        @metadata_pricings |= metadata
      end
    end

    def manipulate_local_charges
      @local_charges.values.flatten.each do |local_charge|
        scheds = default_schedules(tenant_vehicle_id: local_charge.tenant_vehicle_id)
        next if scheds.blank?

        manipulated, metadata = Pricings::Manipulator.new(
          type: "#{local_charge.direction}_margin".to_sym,
          target: @target,
          organization: @organization,
          args: {
            schedules: scheds,
            local_charge: local_charge,
            cargo_class_count: 1,
            sandbox: @sandbox
          }
        ).perform
        @manipulated_local_charges |= manipulated
        @metadata_local_charges |= metadata
      end
    end

    def manipulate_truckings
      @truckings.values.flatten.each do |trucking|
        manipulated, metadata = Pricings::Manipulator.new(
          type: "trucking_#{trucking[:carriage]}_margin".to_sym,
          target: @target,
          organization: @organization,
          args: {
            schedules: default_schedules(tenant_vehicle_id: nil),
            trucking_pricing: trucking,
            date: Date.today,
            cargo_class_count: 1,
            sandbox: @sandbox
          }
        ).perform

        @manipulated_truckings << manipulated.first
        @metadata_truckings |= metadata
      end
    end

    def prepare_trips
      @trips = pricings.map do |pricing|
        trip = ::Legacy::Trip.for_dates(date, date + 5.days).where(
          tenant_vehicle_id: pricing.tenant_vehicle_id,
          itinerary_id: pricing.itinerary_id,
          load_type: pricing.load_type
        ).first

        trip ||= ::Legacy::Trip.create!(
          start_date: date,
          end_date: date + 5.days,
          closing_date: date - 4.days,
          tenant_vehicle_id: pricing.tenant_vehicle_id,
          load_type: pricing.load_type,
          itinerary_id: pricing.itinerary_id
        )

        trip
      end
    end

    private

    def origin_hub_ids
      @truckings['pre'].present? ? @truckings['pre'].map { |trucking| trucking[:hub_id] }.uniq : [@params[:selectedOriginHub]]
    end

    def destination_hub_ids
      @truckings['on'].present? ? @truckings['on'].map { |trucking| trucking[:hub_id] }.uniq : [@params[:selectedDestinationHub]]
    end

    def group_ids
      if @target.is_a?(Organizations::User)
        @hierarchy.select { |hier| hier.is_a?(Groups::Group) }.map(&:id)
      elsif @target.is_a?(Groups::Group)
        [@target.id]
      end
    end

    def pricings
      association = Pricings::Pricing.where(itinerary_id: @itineraries, cargo_class: @cargo_class)
      if @scope.slice(:display_itineraries_with_rates, :dedicated_pricings_only).values.any?(&:present?)
        association = association.where(group_id: group_ids)
      else
        Pricings::Pricing.where(itinerary_id: @itineraries, cargo_class: @cargo_class)
      end
      association.for_dates(date, date + 15.days)
    end

    def default_schedules(tenant_vehicle_id: tenant_vehicles.first.id)
      @trips.select { |trip| trip.tenant_vehicle_id == tenant_vehicle_id }.map { |trip| ::Legacy::Schedule.from_trip(trip) }
    end
  end
end
