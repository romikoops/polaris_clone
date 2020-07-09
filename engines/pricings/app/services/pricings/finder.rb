# frozen_string_literal: true

module Pricings
  class Finder
    attr_accessor :schedules, :tenant_vehicle_id, :start_date, :end_date, :organization,
                  :closing_start_date, :closing_end_date, :cargo_classes, :user_pricing_id

    def initialize( # rubocop:disable Metrics/ParameterLists
      schedules:,
      user_pricing_id:,
      organization:,
      cargo_classes:,
      dates:,
      dedicated_pricings_only:,
      shipment:,
      sandbox: nil
    )
      @shipment = shipment
      @schedules = schedules
      @itinerary = schedules.first.trip.itinerary
      @tenant_vehicle_id = schedules.first.trip.tenant_vehicle_id
      @start_date = dates[:start_date]
      @end_date = dates[:end_date]
      @closing_start_date = dates[:closing_start_date]
      @closing_end_date = dates[:closing_end_date]
      @cargo_classes = cargo_classes
      @organization = organization
      @user = ::Users::User.find(user_pricing_id) if user_pricing_id.present?
      @target = @user
      @target ||= Groups::Group.find_by(organization: organization, name: 'default')
      @scope = ::OrganizationManager::ScopeService.new(target: @target, organization: @organization).fetch
      @hierarchy = ::OrganizationManager::HierarchyService.new(
        target: @target,
        organization: @organization
      ).fetch.select { |target| target.is_a?(Groups::Group) }
      @sandbox = sandbox
      @dedicated_pricings_only = dedicated_pricings_only
    end

    def perform
      pricings_by_cargo_class_and_dates = relevant_pricings_for_journey

      margin_pricings_with_meta_by_cargo_class_and_dates =
        manipulate_pricings_results(pricings: pricings_by_cargo_class_and_dates)

      return [{}, [], {}] if margin_pricings_with_meta_by_cargo_class_and_dates.compact.empty?

      pricings_with_rate_overview, metadata_list =
        resort_manipulated_pricings_and_schedules(data: margin_pricings_with_meta_by_cargo_class_and_dates.compact)
      pricings_to_return, rate_overview = separate_rate_overview(pricings: pricings_with_rate_overview)
      [pricings_to_return, metadata_list, rate_overview]
    end

    def relevant_pricings_for_journey
      pricings_by_cargo_class = pricings_for_cargo_classes_and_groups
      pricings_by_cargo_class_and_dates = pricings_by_cargo_class.for_dates(start_date, end_date)
      ## If etd filter results in no pricings, check using closing_date

      if start_date && end_date && pricings_by_cargo_class_and_dates.empty?

        pricings_by_cargo_class_and_dates = pricings_by_cargo_class
                                            .for_dates(closing_start_date, closing_end_date)
      end

      pricings_by_cargo_class_and_dates
    end

    def manipulate_pricings_results(pricings:)
      pricings.map do |pricing|
        filtered_schedules = schedules_for_pricing(schedules: schedules, pricing: pricing)
        next if filtered_schedules.empty? && !rate_overview_classes.include?(pricing.cargo_class)

        Pricings::Manipulator.new(
          type: :freight_margin,
          target: @target,
          organization: organization,
          args: {
            schedules: filtered_schedules,
            cargo_class_count: @shipment.cargo_classes.count,
            pricing: pricing,
            sandbox: @sandbox
          }
        ).perform
      end
    end

    def separate_rate_overview(pricings:)
      rate_overview = pricings.dup
      pricings_to_return = pricings.slice(*cargo_classes)

      [pricings_to_return, rate_overview]
    end

    def rate_overview_classes
      all_cargo_classes.reject { |cargo_class| @cargo_classes.include?(cargo_class) }
    end

    def all_cargo_classes
      @all_cargo_classes ||= ::Pricings::Pricing
                             .where(itinerary: @itinerary, tenant_vehicle_id: @tenant_vehicle_id)
                             .map(&:cargo_class)
    end

    def target_cargo_classes
      @scope[:show_rate_overview] ? all_cargo_classes : @cargo_classes
    end

    def resort_manipulated_pricings_and_schedules(data:)
      flat_data = data.flatten
      pricings = flat_data.select { |datum| datum['itinerary_id'].present? }
      metadata = flat_data.select { |datum| datum[:pricing_id].present? }
      cargo_classes = pricings.pluck('cargo_class')

      pricings_by_cargo_class = cargo_classes.each_with_object(Hash.new { |h, k| h[k] = [] }) do |cargo_class, hash|
        hash[cargo_class] = pricings.select { |pricing| pricing['cargo_class'] == cargo_class }
      end

      [pricings_by_cargo_class, metadata]
    end

    def pricings_for_cargo_classes_and_groups
      query = ::Pricings::Pricing.where(
        internal: false,
        tenant_vehicle_id: tenant_vehicle_id,
        itinerary_id: schedules.first.trip.itinerary_id,
        organization_id: @shipment.organization_id,
        sandbox: @sandbox
      ).for_cargo_classes(target_cargo_classes)

      @hierarchy.reverse_each do |group|
        group_result = query.where(group_id: group.id, user_id: nil)
        return group_result unless group_result.empty?
      end

      query.where(group_id: nil)
    end

    def schedules_for_pricing(schedules:, pricing:)
      return schedules if schedules.length == 1 && schedules.first.etd.nil?

      pricing_schedules = schedules.select do |sched|
        (pricing.effective_date..pricing.expiration_date).cover?(sched.etd)
      end
      if pricing_schedules.empty?
        pricing_schedules = schedules.select do |sched|
          (pricing.effective_date..pricing.expiration_date).cover?(sched.closing_date)
        end
      end

      pricing_schedules
    end
  end
end
