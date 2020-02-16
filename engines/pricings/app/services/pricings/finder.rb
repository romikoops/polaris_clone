# frozen_string_literal: true

module Pricings
  class Finder
    attr_accessor :schedules, :tenant_vehicle_id, :start_date, :end_date,
                  :closing_start_date, :closing_end_date, :cargo_classes, :user_pricing_id

    def initialize( # rubocop:disable Metrics/ParameterLists
      schedules:,
      user_pricing_id:,
      cargo_classes:,
      dates:,
      dedicated_pricings_only:,
      shipment:,
      sandbox: nil
    )
      @shipment = shipment
      @schedules = schedules
      @tenant_vehicle_id = schedules.first.trip.tenant_vehicle_id
      @start_date = dates[:start_date]
      @end_date = dates[:end_date]
      @closing_start_date = dates[:closing_start_date]
      @closing_end_date = dates[:closing_end_date]
      @cargo_classes = cargo_classes
      @user = ::Tenants::User.find_by(legacy_id: user_pricing_id)
      @hierarchy = ::Tenants::HierarchyService.new(target: @user).fetch.select { |target| target.is_a?(Tenants::Group) }
      @sandbox = sandbox
    end

    def perform
      pricings_by_cargo_class = pricings_for_cargo_classes_and_groups
      pricings_by_cargo_class_and_dates = pricings_by_cargo_class.for_dates(start_date, end_date)

      ## If etd filter results in no pricings, check using closing_date
      if start_date && end_date && pricings_by_cargo_class_and_dates.empty?
        pricings_by_cargo_class_and_dates = pricings_by_cargo_class
                                            .for_dates(closing_start_date, closing_end_date)
      end

      margin_pricings_with_meta_by_cargo_class_and_dates = pricings_by_cargo_class_and_dates.map do |pricing|
        filtered_schedules = schedules_for_pricing(schedules: schedules, pricing: pricing)
        next if filtered_schedules.empty?

        Pricings::Manipulator.new(
          type: :freight_margin,
          target: @user,
          tenant: @user.tenant,
          args: {
            schedules: filtered_schedules,
            cargo_class_count: @shipment.cargo_classes.count,
            pricing: pricing,
            sandbox: @sandbox
          }
        ).perform
      end

      return {} if margin_pricings_with_meta_by_cargo_class_and_dates.compact.empty?

      pricings_to_return, metadata_list = resort_manipulated_pricings_and_schedules(data: margin_pricings_with_meta_by_cargo_class_and_dates.compact)

      [pricings_to_return, metadata_list]
    end

    def resort_manipulated_pricings_and_schedules(data:)
      flat_data = data.flatten
      pricings = flat_data.select { |datum| datum['itinerary_id'].present? }
      metadata = flat_data.select { |datum| datum[:pricing_id].present? }
      cargo_classes = pricings.pluck('cargo_class')
      result_hashes = []
      current_hash = {}

      pricings_by_cargo_class = cargo_classes.each_with_object(Hash.new { |h, k| h[k] = [] }) do |cargo_class, hash|
        hash[cargo_class] = pricings.select {|pricing| pricing['cargo_class'] == cargo_class }
      end

      [pricings_by_cargo_class, metadata]
    end

    def pricings_for_cargo_classes_and_groups
      query = ::Pricings::Pricing.where(
        internal: false,
        tenant_vehicle_id: tenant_vehicle_id,
        itinerary_id: schedules.first.trip.itinerary_id,
        cargo_class: cargo_classes,
        user_id: nil,
        tenant_id: @shipment.tenant_id,
        sandbox: @sandbox
      )

      @hierarchy.reverse_each do |group|
        group_result = query.where(group_id: group.id)
        return group_result unless group_result.empty?
      end

      query.where(group_id: nil)
    end

    def schedules_for_pricing(schedules:, pricing:)
      return schedules if schedules.length == 1 && schedules.first.etd.nil?

      pricing_schedules = schedules.select do |sched|
        sched.etd < pricing.expiration_date && sched.etd > pricing.effective_date
      end
      if pricing_schedules.empty?
        pricing_schedules = schedules.select do |sched|
          sched.closing_date < pricing.expiration_date && sched.closing_date > pricing.effective_date
        end
      end

      pricing_schedules
    end
  end
end
