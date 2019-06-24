# frozen_string_literal: true

module Pricings
  class Preview # rubocop:disable Metrics/ClassLength
    attr_accessor :itinerary, :tenant_vehicle_id, :cargo_class, :target, :date, :tenant

    def initialize(itinerary_id:, target:, cargo_class: nil, tenant_vehicle_id: nil, date: Date.today + 5.days)
      @itinerary = ::Legacy::Itinerary.find(itinerary_id)
      @legacy_tenant = @itinerary.tenant
      @target = target
      @tenant = ::Tenants::Tenant.find_by(legacy_id: itinerary.tenant_id)
      args = {
        itinerary_id: itinerary_id
      }
      args[:cargo_class] = cargo_class if cargo_class
      args[:tenant_vehicle_id] = tenant_vehicle_id if tenant_vehicle_id
      @pricings = ::Pricings::Pricing.for_dates(date, date + 5.days).where(args)
      @margins = ::Pricings::Margin.where(margin_type: :freight_margin).for_dates(date, date + 5.days)
      @pricings_to_return = []
      @date = date
    end

    def perform
      margin_preview = @pricings.map do |pricing|
        @pricing = pricing
        schedules = create_schedules_for_pricing(pricing: pricing)

        next if schedules.empty?

        @applicable_margins = find_applicable_margins
        @margins_to_apply = sort_margins
        manipulate_pricings
      end
      margin_preview
    end

    def find_applicable_margins # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      hierachy = case target.class.to_s
                 when 'Tenants::Group'
                   [
                     { rank: 0, data: [target] },
                     { rank: 1, data: target.memberships || [] }
                   ]
                 when 'Tenants::Company'
                   [
                     { rank: 0, data: [target] },
                     { rank: 1, data: target.memberships || [] }
                   ]
                 when 'Tenants::User'
                   [
                     { rank: 0, data: [target] },
                     { rank: 1, data: target.memberships || [] },
                     { rank: 2, data: [target&.company] || [] },
                     { rank: 3, data: target&.company&.memberships || [] }
                   ]
                end
      all_margins = apply_hierarchy(hierachy)
      return all_margins unless all_margins.empty?

      tenant_h = [
        { rank: 0, data: [target.tenant] }
      ]

      apply_hierarchy(tenant_h)
    end

    def create_schedules_for_pricing(pricing:)
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

      [trip]
    end

    def apply_hierarchy(hierarchy) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      default_args = [
        {
          tenant_id: @tenant.id,
          pricing: @pricing,
          default_for: nil
        },
        {
          tenant_id: @tenant.id,
          itinerary_id: itinerary.id,
          tenant_vehicle_id: tenant_vehicle_id,
          cargo_class: cargo_class,
          default_for: nil
        },
        {
          tenant_id: @tenant.id,
          origin_hub_id: itinerary.ordered_hub_ids.first,
          tenant_vehicle_id: tenant_vehicle_id,
          cargo_class: cargo_class
        },
        {
          tenant_id: @tenant.id,
          destination_hub_id: itinerary.ordered_hub_ids.last,
          tenant_vehicle_id: tenant_vehicle_id,
          cargo_class: cargo_class
        },
        {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: nil,
          tenant_vehicle_id: tenant_vehicle_id,
          cargo_class: cargo_class,
          default_for: nil
        },
        {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: itinerary.id,
          cargo_class: nil,
          tenant_vehicle_id: nil,
          default_for: nil
        },
        {
          tenant_id: @tenant.id,
          origin_hub_id: itinerary.ordered_hub_ids.first,
          destination_hub_id: itinerary.ordered_hub_ids.last,
          itinerary_id: nil,
          cargo_class: nil,
          tenant_vehicle_id: nil,
          default_for: nil
        },
        {
          tenant_id: @tenant.id,
          destination_hub_id: itinerary.ordered_hub_ids.last,
          itinerary_id: nil,
          cargo_class: nil,
          tenant_vehicle_id: nil,
          default_for: nil
        },
        {
          tenant_id: @tenant.id,
          origin_hub_id: itinerary.ordered_hub_ids.first,
          itinerary_id: nil,
          cargo_class: nil,
          tenant_vehicle_id: nil,
          default_for: nil
        },
        {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: nil,
          cargo_class: nil,
          tenant_vehicle_id: tenant_vehicle_id,
          default_for: nil
        },
        {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: nil,
          tenant_vehicle_id: nil,
          cargo_class: cargo_class,
          default_for: nil
        },
        {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: nil,
          tenant_vehicle_id: nil,
          cargo_class: nil,
          default_for: itinerary.mode_of_transport
        },
        {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: nil,
          tenant_vehicle_id: nil,
          cargo_class: nil,
          default_for: nil
        }
      ]
      all_margins = []
      all_margin_ids = []
      default_args.each do |args|
        hierarchy.each do |h_data|
          h_data[:data].each do |target|
            args[:applicable] = target.is_a?(::Tenants::Membership) ? target.group : target
            margins = find_margins_for(args)
            margins.uniq.each do |m|
              next if all_margin_ids.include?(m.id)

              prio = target.is_a?(::Tenants::Membership) ? target.priority : 0
              all_margins << { priority: prio, margin: m, rank: h_data[:rank] }
              all_margin_ids << m.id
            end
          end
        end
      end

      all_margins
    end

    def sort_margins # rubocop:disable Metrics/AbcSize
      margin_periods = @applicable_margins.group_by { |x| x[:margin].slice(:effective_date, :expiration_date) }
      if margin_periods.keys.length == 1
        margin_periods.values.first.sort_by! { |x| [x[:margin][:application_order], x[:rank], x[:priority]] }
        return margin_periods
      end
      new_margin_periods = {}
      date_keys = margin_periods.keys.map(&:values).flatten.uniq.sort
      new_date_keys = date_keys.map.with_index do |date, i|
        effective_date = date.hour == 23 ? date.beginning_of_day + 1.day : date.beginning_of_day
        next_date = date_keys[i + 1]
        next unless next_date

        expiration_date = next_date.hour == 23 ? next_date : next_date.end_of_day - 1.day
        {
          effective_date: effective_date,
          expiration_date: expiration_date
        }
      end

      new_date_keys.compact.each do |dk|
        new_margin_periods[dk] = @applicable_margins.select do |m|
          m[:margin][:expiration_date] >= dk[:effective_date] &&
            m[:margin][:effective_date] <= dk[:expiration_date]
        end.sort_by! { |x| [x[:margin][:application_order], x[:rank], x[:priority]] }
      end

      new_margin_periods
    end

    def find_margins_for(args)
      margins = @margins.where(tenant_id: @tenant.id, pricing: @pricing, applicable: args[:applicable])
      return margins unless margins.empty?

      margins = @margins.where(args)
      margins
    end

    def manipulate_pricings # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      @pricings_to_return = @margins_to_apply.map do |date_keys, data| # rubocop:disable Metrics/BlockLength
        fees = @pricing.fees
        fee_hash = {}
        fee_snapshots = data.map do |mdata|
          margin = mdata[:margin]
          fees.each do |fee|
            fee_json = fee.as_json

            effective_margin = (margin.details.find_by(charge_category_id: fee.charge_category_id) || margin)
            effective_value = if effective_margin.operator == '+' && effective_margin == margin
                                effective_margin.value / fees.size
                              else
                                effective_margin.value
                              end
            result_json = apply_manipulation(
              operator: effective_margin.operator,
              value: effective_value,
              fee: fee_hash[fee.fee_code] || fee_json.values.first
            )
            fee_hash[fee.fee_code] = result_json
          end

          {
            fees: fee_hash.dup,
            applicable: applicable_string(margin: margin),
            margin: margin_json_data(margin)
          }
        end
        new_effective_date, new_expiration_date = manipulate_dates(date_keys)
        manipulated_pricing = @pricing.as_json
        manipulated_pricing['effective_date'] = new_effective_date
        manipulated_pricing['expiration_date'] = new_expiration_date
        manipulated_pricing['manipulation_steps'] = fee_snapshots
        manipulated_pricing['itinerary'] = @itinerary
        manipulated_pricing['service_level'] = @pricing.tenant_vehicle.full_name
        manipulated_pricing.with_indifferent_access
      end
    end

    def margin_json_data(margin, options = {})
      new_options = options.reverse_merge(
        methods: %i(service_level itinerary_name fee_code cargo_class mode_of_transport)
      )
      margin.as_json(new_options).reverse_merge(
        marginDetails: margin.details.map { |d| margin_detail_json_data(d) }
      ).deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    def margin_detail_json_data(detail, options = {})
      new_options = options.reverse_merge(
        methods: %i(rate_basis itinerary_name fee_code)
      )
      detail.as_json(new_options)
    end

    def determine_manipulation(rate:, value:, operator:)
      case operator
      when '%'
        apply_percentage(value: value, rate: rate)
      when '+'
        apply_addition(value: value, rate: rate)
      end
    end

    def apply_manipulation(value:, operator:, fee:)
      new_fee = fee.dup

      new_fee['rate'] = determine_manipulation(rate: fee['rate'].to_d, value: value, operator: operator)
      new_fee['min'] = determine_manipulation(rate: fee['min'].to_d, value: value, operator: operator) if fee['min']
      return new_fee if fee['range'].nil? || fee['range'].empty?

      new_fee['range'] = fee['range'].map do |range|
        range['rate'] = determine_manipulation(rate: range['rate'].to_d, value: value, operator: operator)
        range['min'] = determine_manipulation(rate: range['min'].to_d, value: value, operator: operator) if range['min']
        range
      end

      new_fee
    end

    def manipulate_dates(date_keys)
      effective_date = @pricing.effective_date
      expiration_date = @pricing.expiration_date
      effective_date = date_keys[:effective_date] if date_keys[:effective_date] > effective_date
      expiration_date = date_keys[:expiration_date] if date_keys[:expiration_date] < expiration_date
      [effective_date, expiration_date]
    end

    def apply_percentage(value:, rate:)
      return rate.to_d if value.zero?

      rate.to_d * (1 + value)
    end

    def apply_addition(value:, rate:)
      rate.to_d + value
    end

    def applicable_string(margin:)
      case margin.applicable.class.to_s
      when 'Tenants::Group'
        "Group: #{margin.applicable.name}"
      when 'Tenants::Company'
        "Company: #{margin.applicable.name}"
      when 'Tenants::Tenant'
        "Tenant: #{margin.applicable.legacy.name}"
      when 'Tenants::User'
        "User: #{margin.applicable.legacy.full_name}"
      else
        "User: #{margin.applicable.full_name}"
      end
    end
  end
end
