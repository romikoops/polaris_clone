# frozen_string_literal: true

module Pricings
  class Manipulator # rubocop:disable Metrics/ClassLength
    MissingArgument = Class.new(StandardError)
    def initialize(type:, user:, args:)
      argument_errors(type, user, args)
      @type = type
      @user = user
      @tenant = @user.tenant
      @shipment = args[:shipment]
      @meta = @shipment.meta
      if @type == :freight_margin
        freight_variables(args: args)
      elsif %i(trucking_pre_margin trucking_on_margin).include?(@type)
        trucking_variables(args: args)
      elsif %i(import_margin export_margin).include?(@type)
        local_charge_variables(args: args)
      end
    end

    def perform
      @applicable_margins = find_applicable_margins
      @margins_to_apply = sort_margins
      manipulate_pricings
      @pricings_to_return.compact
    end

    def find_applicable_margins
      user_h = [
        { rank: 0, data: [@user] },
        { rank: 1, data: @user.memberships || [] },
        { rank: 2, data: @user&.company&.memberships || [] }
      ]
      all_margins = apply_hierarchy(user_h)

      return all_margins unless all_margins.empty?

      tenant_h = [
        { rank: 0, data: [@user.tenant] }
      ]

      apply_hierarchy(tenant_h)
    end

    def apply_hierarchy(hierarchy) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength
      # Dynamically generates the arguments for the margin finder based on the inputs handed to the Manipulator. 
      # Required due to the differing data points for freight v local_charge v trucking 
      default_args = []
      if @pricing
        default_args.push(
          tenant_id: @tenant.id,
          pricing: @pricing
        )
      end
      if @itinerary && @cargo_class && @tenant_vehicle_id
        default_args << {
          tenant_id: @tenant.id,
          itinerary_id: @itinerary.id,
          tenant_vehicle_id: @tenant_vehicle_id,
          cargo_class: @cargo_class
        }
      end
      if @origin_hub_id && @tenant_vehicle_id && @cargo_class
        default_args << {
          tenant_id: @tenant.id,
          origin_hub_id: @origin_hub_id,
          tenant_vehicle_id: @tenant_vehicle_id,
          cargo_class: @cargo_class
        }
      end
      if @destination_hub_id && @tenant_vehicle_id && @cargo_class
        default_args << {
          tenant_id: @tenant.id,
          destination_hub_id: @destination_hub_id,
          tenant_vehicle_id: @tenant_vehicle_id,
          cargo_class: @cargo_class
        }
      end
      if @tenant_vehicle_id && @cargo_class
        default_args << {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: nil,
          tenant_vehicle_id: @tenant_vehicle_id,
          cargo_class: @cargo_class
        }
      end
      if @itinerary
        default_args << {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: @itinerary.id,
          cargo_class: nil,
          tenant_vehicle_id: nil
        }
      end
      if @origin_hub_id && @destination_hub_id
        default_args << {
          tenant_id: @tenant.id,
          origin_hub_id: @origin_hub_id,
          destination_hub_id: @destination_hub_id,
          itinerary_id: nil,
          cargo_class: nil,
          tenant_vehicle_id: nil
        }
      end
      if @destination_hub_id && @cargo_class
        default_args << {
          tenant_id: @tenant.id,
          destination_hub_id: @destination_hub_id,
          itinerary_id: nil,
          cargo_class: @cargo_class,
          tenant_vehicle_id: nil
        }
      end
      if @origin_hub_id && @cargo_class
        default_args << {
          tenant_id: @tenant.id,
          origin_hub_id: @origin_hub_id,
          itinerary_id: nil,
          cargo_class: @cargo_class,
          tenant_vehicle_id: nil
        }
      end
      if @destination_hub_id
        default_args << {
          tenant_id: @tenant.id,
          destination_hub_id: @destination_hub_id,
          itinerary_id: nil,
          cargo_class: nil,
          tenant_vehicle_id: nil
        }
      end
      if @origin_hub_id
        default_args << {
          tenant_id: @tenant.id,
          origin_hub_id: @origin_hub_id,
          itinerary_id: nil,
          cargo_class: nil,
          tenant_vehicle_id: nil
        }
      end
      if @tenant_vehicle_id
        default_args << {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: nil,
          cargo_class: nil,
          tenant_vehicle_id: @tenant_vehicle_id
        }
      end
      if @cargo_class
        default_args << {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: nil,
          tenant_vehicle_id: nil,
          cargo_class: @cargo_class
        }
      end
      if @itinerary
        default_args << {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: nil,
          tenant_vehicle_id: nil,
          cargo_class: nil,
          default_for: @itinerary&.mode_of_transport
        }
      end
      if @itinerary.nil?
        default_args << {
          tenant_id: @tenant.id,
          origin_hub_id: nil,
          destination_hub_id: nil,
          itinerary_id: nil,
          tenant_vehicle_id: nil,
          cargo_class: nil,
          default_for: @type.to_s.include?('trucking') ? 'trucking' : 'local_charge'
        }
      end
      default_args << {
        tenant_id: @tenant.id,
        origin_hub_id: nil,
        destination_hub_id: nil,
        itinerary_id: nil,
        tenant_vehicle_id: nil,
        cargo_class: nil,
        default_for: nil
      }
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

    def sort_margins # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength
      outer_date = if @type == :freight_margin
                     @pricing.expiration_date
                   elsif %i(trucking_pre_margin trucking_on_margin).include?(@type)
                     @end_date
                   else
                     @local_charge.expiration_date
                        end
      margin_periods = @applicable_margins.group_by { |x| x[:margin].slice(:effective_date, :expiration_date) }
      if margin_periods.keys.length == 1
        margin_periods.values.first.sort_by! { |x| [x[:margin][:application_order], x[:rank], x[:priority]] }
        return margin_periods
      end
      date_keys = margin_periods.keys
                                .reject { |dk| dk[:effective_date] > outer_date }
                                .map(&:values)
                                .flatten
                                .uniq
                                .sort
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

      new_margin_periods = new_date_keys.compact.each_with_object({}) do |dk, hash|
        hash[dk] = {}
        hash[dk][:margins] = @applicable_margins.select do |m|
          m[:margin][:expiration_date] >= dk[:effective_date] &&
            m[:margin][:effective_date] <= dk[:expiration_date]
        end.sort_by! { |x| [x[:margin][:application_order], x[:rank], x[:priority]] }
        hash[dk][:dates] = dk
        hash
      end

      final_margin_periods = {}
      new_margin_periods.values
                        .group_by { |nmp| nmp[:margins].map { |m| m[:margin][:id] } }
                        .values.each do |mp|
                          all_effective_dates = mp.map { |obj| obj[:dates][:effective_date] }
                          all_expiration_dates = mp.map { |obj| obj[:dates][:expiration_date] }
                          final_date_key = {
                            effective_date: all_effective_dates.min,
                            expiration_date: all_expiration_dates.max
                          }
                          final_margin_periods[final_date_key] = mp.first[:margins]
                        end
      final_margin_periods
    end

    def find_margins_for(args)
      margins = @margins.where(tenant_id: @tenant.id, pricing: @pricing, applicable: args[:applicable])
      return margins unless margins.empty?

      margins = @margins.where(args)
      margins
    end

    def manipulate_pricings
      if @type == :freight_margin
        manipulate_freight_pricings
      elsif %i(trucking_pre_margin trucking_on_margin).include?(@type)
        manipulate_trucking_pricings
      elsif %i(import_margin export_margin).include?(@type)
        manipulate_local_charges
      end
    end

    def manipulate_freight_pricings # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      @pricings_to_return = @margins_to_apply.map do |date_keys, data| # rubocop:disable Metrics/BlockLength
        fees = @pricing.fees
        fee_count = fees.select { |f| f.fee_code&.include?('unknown') || f.fee_code&.include?('included') }.size
        fee_count = 1 if fee_count.zero?
        fee_hash = fees.each_with_object({}) do |fee, hash|
          fee_json = fee.as_json
          fee_code = fee.fee_code
          next if fee_code.nil?

          data.each do |mdata|
            margin = mdata[:margin]
            effective_margin = (margin.details.find_by(charge_category_id: fee.charge_category_id) || margin)
            effective_value = if effective_margin.operator == '+' && effective_margin == margin
                                effective_margin.value / fee_count
                              else
                                effective_margin.value
                              end

            result_json = apply_freight_manipulation(
              operator: effective_margin.operator,
              value: effective_value,
              fee: hash[fee_code] || fee_json.values.first
            )

            hash[fee_code] = result_json
          end
        end
        new_effective_date, new_expiration_date = manipulate_dates(@pricing, date_keys)
        manipulated_pricing = @pricing.as_json
        manipulated_pricing['effective_date'] = new_effective_date
        manipulated_pricing['expiration_date'] = new_expiration_date
        manipulated_pricing['data'] = fee_hash
        update_meta(manipulated_pricing, data)
        manipulated_pricing.with_indifferent_access
      end
    end

    def manipulate_local_charges # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength
      @pricings_to_return = @margins_to_apply.map do |date_keys, data| # rubocop:disable Metrics/BlockLength
        fees = @local_charge.fees

        fee_hash = fees.each_with_object({}) do |(key, fee), hash|
          charge_category = ::Legacy::ChargeCategory.find_by(code: key, tenant: @tenant.legacy_id)
          data.each do |mdata|
            margin = mdata[:margin]
            effective_margin = (margin.details.find_by(charge_category_id: charge_category&.id) || margin)
            effective_value = if effective_margin.operator == '+' && effective_margin == margin
                                effective_margin.value / fees.values.size
                              else
                                effective_margin.value
                              end
            result_json = apply_local_charge_manipulation(
              operator: effective_margin.operator,
              value: effective_value,
              fee: hash[key] || fee
            )
            hash[key] = result_json
          end
        end

        new_effective_date, new_expiration_date = manipulate_dates(@local_charge, date_keys)
        next if new_effective_date > new_expiration_date
        next if fee_hash.empty?

        manipulated_pricing = @local_charge.as_json
        manipulated_pricing['effective_date'] = new_effective_date
        manipulated_pricing['expiration_date'] = new_expiration_date
        manipulated_pricing['fees'] = fee_hash
        update_meta(manipulated_pricing, data)

        manipulated_pricing.with_indifferent_access
      end
    end

    def manipulate_trucking_pricings # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength
      @pricings_to_return = @margins_to_apply.map do |date_keys, data| # rubocop:disable Metrics/BlockLength
        fees = @trucking_pricing.fees
        fee_hash = fees.each_with_object({}) do |(key, fee), hash|
          charge_category = ::Legacy::ChargeCategory.find_by(code: key, tenant: @tenant.legacy_id)
          data.each do |mdata|
            margin = mdata[:margin]
            effective_margin = (margin.details.find_by(charge_category_id: charge_category&.id) || margin)
            effective_value = if effective_margin.operator == '+' && effective_margin == margin
                                effective_margin.value / fees.values.size
                              else
                                effective_margin.value
                              end
            result_json = apply_trucking_fee_manipulation(
              operator: effective_margin.operator,
              value: effective_value,
              fee: hash[key] || fee
            )
            hash[key] = result_json
          end
        end
        rates_hash = @trucking_pricing.rates.each_with_object({}) do |(key, range), hash|
          data.each do |mdata|
            margin = mdata[:margin]
            effective_margin = (margin.details.find_by(charge_category_id: @trucking_charge_category&.id) || margin)
            effective_value = if effective_margin.operator == '+' && effective_margin == margin
                                effective_margin.value / fees.size
                              else
                                effective_margin.value
                              end
            result_json = apply_trucking_rate_manipulation(
              operator: effective_margin.operator,
              value: effective_value,
              rates: range
            )

            hash[key] = result_json
          end
        end
        manipulated_pricing = @trucking_pricing.as_json
        manipulated_pricing['fees'] = fee_hash
        manipulated_pricing['rates'] = rates_hash
        manipulated_pricing['effective_date'] =  date_keys[:effective_date]
        manipulated_pricing['expiration_date'] = date_keys[:expiration_date]
        update_meta(manipulated_pricing, data)
        manipulated_pricing.with_indifferent_access
      end
    end

    def update_meta(pricing, data)
      @meta[@type] ||= {}
      key = [pricing['effective_date'], pricing['expiration_date'], pricing['id']].join('-')
      @meta[@type][key] = data.map { |md| md[:margin][:id] }
      @shipment.save!
    end

    def manipulate_dates(pricing, date_keys)
      effective_date = pricing.effective_date
      expiration_date = pricing.expiration_date
      effective_date = date_keys[:effective_date] if date_keys[:effective_date] > effective_date
      expiration_date = date_keys[:expiration_date] if date_keys[:expiration_date] < expiration_date
      [effective_date, expiration_date]
    end

    def determine_manipulation(rate:, value:, operator:)
      case operator
      when '%'
        apply_percentage(value: value, rate: rate)
      when '+'
        apply_addition(value: value, rate: rate)
      end
    end

    def apply_freight_manipulation(value:, operator:, fee:)
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

    def apply_local_charge_manipulation(value:, operator:, fee:)
      new_fee = fee.dup.with_indifferent_access
      only_values = fee.except('name', 'key', 'currency', 'rate_basis', 'range', 'effective_date', 'expiration_date')
      only_values.keys.each do |k|
        new_fee[k] = determine_manipulation(rate: fee[k].to_d, value: value, operator: operator) if fee[k]
      end

      return new_fee if fee['range'].nil? || fee['range'].empty?

      new_fee['range'] = fee['range'].map do |range|
        range.except('name', 'currency', 'rate_basis', 'max', 'min').keys.each do |rk|
          range[rk] = determine_manipulation(rate: range[rk].to_d, value: value, operator: operator) if range[rk]
        end
        range
      end

      new_fee
    end

    def apply_trucking_fee_manipulation(value:, operator:, fee:)
      new_fee = fee.dup
      only_values = fee.except('name', 'key', 'currency', 'rate_basis', 'range', 'effective_date', 'expiration_date')
      only_values.keys.each do |k|
        new_fee[k] = determine_manipulation(rate: fee[k].to_d, value: value, operator: operator) if fee[k]
      end
      return new_fee if fee['range'].nil? || fee['range'].empty?

      new_fee['range'] = fee['range'].map do |range|
        range.except('name', 'currency', 'rate_basis', 'max', 'min').keys.each do |rk|
          range[rk] = determine_manipulation(rate: range[rk].to_d, value: value, operator: operator) if range[rk]
        end
        range
      end

      new_fee
    end

    def apply_trucking_rate_manipulation(value:, operator:, rates:)
      new_rates = rates.map do |rate|
        new_rate = rate.dup
        new_rate['rate']['value'] = determine_manipulation(rate: rate['rate']['value'].to_d, value: value, operator: operator)
        new_rate['min_value'] = determine_manipulation(rate: rate['min_value'].to_d, value: value, operator: operator)
        new_rate
      end

      new_rates
    end

    def apply_percentage(value:, rate:)
      return rate.to_d if value.zero?

      rate.to_d * (1 + value)
    end

    def apply_addition(value:, rate:)
      rate.to_d + value
    end

    def freight_variables(args:) # rubocop:disable Metrics/AbcSize
      @schedules = args[:schedules].sort_by!(&:etd)

      @start_date = @schedules.first.etd
      @end_date = @schedules.last.eta

      if args[:pricing]
        @pricing = args[:pricing]
        @margins = ::Pricings::Margin.for_dates(@pricing.effective_date, @pricing.expiration_date).where(margin_type: @type)
        @tenant_vehicle_id = @pricing.tenant_vehicle_id
        @cargo_class = @pricing.cargo_class
      else
        @pricing = ::Legacy::Itinerary.find(args[:itinerary_id])&.rates&.for_dates(@start_date, @end_date)&.find_by(
          tenant_vehicle_id: args[:tenant_vehicle_id],
          cargo_class: args[:cargo_class],
          itinerary_id: args[:itinerary_id],
          tenant_id: @user.tenant.legacy_id
        )
        @tenant_vehicle_id = args[:tenant_vehicle_id]
        @cargo_class = args[:cargo_class]
        @margins = ::Pricings::Margin
                   .where(margin_type: @type, tenant_id: @tenant.id)
                   .for_dates(@start_date, @end_date)
      end

      @itinerary = @pricing.itinerary
      @origin_hub_id = @itinerary.ordered_hub_ids.first
      @destination_hub_id = @itinerary.ordered_hub_ids.last
      @pricing_to_return = @pricing.as_json
    end

    def trucking_variables(args:)
      query_args = { margin_type: @type, tenant_id: @tenant.id }
      @trucking_pricing = args[:trucking_pricing]
      if @type == :trucking_pre_margin
        @trucking_charge_category = ::Legacy::ChargeCategory.find_by(tenant_id: @user.tenant_id, code: 'trucking_pre')
        @destination_hub_id = @trucking_pricing.hub_id
      else
        @trucking_charge_category = ::Legacy::ChargeCategory.find_by(tenant_id: @user.tenant_id, code: 'trucking_on')
        @origin_hub_id = @trucking_pricing.hub_id
      end
      @start_date = args[:date]
      @end_date = args[:date] + 30.days
      @margins = ::Pricings::Margin.where(query_args).for_dates(@start_date, @end_date)
    end

    def local_charge_variables(args:)
      query_args = { margin_type: @type, tenant_id: @tenant.id }
      @local_charge = args[:local_charge]
      @counterpart_hub_id = @local_charge.counterpart_hub_id
      if @type == :import_margin
        @destination_hub_id = @local_charge.hub_id
      else
        @origin_hub_id = @local_charge[:hub_id]
      end
      @start_date = args[:schedules].first.etd || Date.today + 4.days
      @end_date = args[:schedules].last.eta || Date.today + 24.days
      @margins = ::Pricings::Margin.where(query_args).for_dates(@start_date, @end_date)
    end

    def argument_errors(_type, user, args) # rubocop:disable Metrics/CyclomaticComplexity
      raise Pricings::Manipulator::MissingArgument unless user
      raise Pricings::Manipulator::MissingArgument unless user.is_a?(Tenants::User)
      raise Pricings::Manipulator::MissingArgument unless args[:shipment]
      raise Pricings::Manipulator::MissingArgument unless (args[:schedules].present? && @type == :freight_margin) || @type != :freight_margin
    end
  end
end
