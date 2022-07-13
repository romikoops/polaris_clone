# frozen_string_literal: true

module Pricings
  class Manipulator
    MissingArgument = Class.new(StandardError)
    TRUCKING_QUERY_DAYS = 10
    RATE_VALUE_KEYS = %w[ton cbm kg item shipment bill container wm percentage rate value].freeze

    def initialize(type:, target:, organization:, args:)
      @type = type
      @target = target || Groups::Group.find_by(name: "default", organization: organization)
      @organization = organization
      @scope = OrganizationManager::ScopeService.new(target: target, organization: organization).fetch
      @cargo_unit_id = args[:cargo_unit_id]
      @meta = {}
      if @type == :freight_margin
        freight_variables(args: args)
      elsif %i[trucking_pre_margin trucking_on_margin].include?(@type)
        trucking_variables(args: args)
      elsif %i[import_margin export_margin].include?(@type)
        local_charge_variables(args: args)
      end
      @cargo_count = args[:cargo_class_count]
    end

    def perform
      pricings_to_return.compact
    end

    def applicable_margins
      @applicable_margins ||= target_margins.presence || organization_margins
    end

    def target_margins
      apply_hierarchy(target_hierarchy: hierarchy)
    end

    def organization_margins
      apply_hierarchy(target_hierarchy: [{ rank: 0, data: [organization] }], for_organization: true)
    end

    def apply_hierarchy(target_hierarchy:, for_organization: false)
      return [] if target_hierarchy.empty?

      permutations = margin_params.product(target_hierarchy).uniq
      base_args, base_target = permutations.first
      base_query = margins.where(base_args.merge(applicable: base_target[:data]))

      margin_relation = permutations.drop(1).inject(base_query) do |query, (args, hier)|
        next query unless margins.exists?(args.merge(applicable: hier[:data]))

        query.or(margins.where(args.merge(applicable: hier[:data])))
      end

      decorated_margins = decorate_margins(input_margins: margin_relation.distinct.to_a, target_hierarchy: target_hierarchy)
      handle_default_margin(margins: decorated_margins, for_organization: for_organization)
    end

    def handle_default_margin(margins:, for_organization:)
      return margins if default_margin.blank?

      not_empty_non_dedicated = scope[:dedicated_pricings_only].blank? && !margins.empty?
      for_organization_and_empty = for_organization && margins.empty?
      margins << {priority: 0, margin: default_margin, rank: 0} if not_empty_non_dedicated || for_organization_and_empty
      margins
    end

    def hierarchy
      OrganizationManager::HierarchyService.new(target: target, organization: organization).fetch
        .reverse.reject { |hier| hier == organization }.map.with_index { |hier, rank| { rank: rank, data: hier } }
    end

    def margin_params
      # Dynamically generates the arguments for the margin finder based on the inputs handed to the Manipulator.
      itinerary_targets = [itinerary&.id, nil]
      origin_hub_targets = [origin_hub_id, nil]
      destination_hub_targets = [destination_hub_id, nil]
      tenant_vehicle_targets = [tenant_vehicle_id, nil]
      cargo_class_targets = [cargo_class, nil]
      pricing_targets = [pricing&.id, nil]

      params = itinerary_targets.product(
        origin_hub_targets,
        destination_hub_targets,
        tenant_vehicle_targets,
        cargo_class_targets,
        pricing_targets
      ).map { |product|
        {
          organization_id: organization.id,
          itinerary_id: product[0],
          origin_hub_id: product[1],
          destination_hub_id: product[2],
          tenant_vehicle_id: product[3],
          cargo_class: product[4],
          pricing_id: product[5]
        }
      }

      params.uniq
    end

    def outer_date
      @outer_date ||= if type == :freight_margin
        pricing.expiration_date
      elsif %i[trucking_pre_margin trucking_on_margin].include?(type)
        end_date
      else
        local_charge.expiration_date
      end
    end

    def extract_date_keys(margin_periods:)
      margin_periods.keys
        .reject { |dk| dk[:effective_date] > outer_date }
        .map(&:values)
        .flatten
        .uniq
        .sort
    end

    def adjusted_date_keys(margin_periods:)
      date_keys = extract_date_keys(margin_periods: margin_periods)
      result_date_keys = date_keys.map.with_index { |date, i|
        effective_date = date.hour == 23 ? date.beginning_of_day + 1.day : date.beginning_of_day
        effective_date = DateTime.now.utc.beginning_of_day if effective_date < DateTime.now
        next_date = date_keys[i + 1]
        next unless next_date

        expiration_date = next_date.hour == 23 ? next_date : next_date.end_of_day - 1.day

        next if expiration_date < effective_date

        {
          effective_date: effective_date,
          expiration_date: expiration_date
        }
      }
      result_date_keys.compact
    end

    def final_margin_periods(margin_periods:)
      adjusted_date_keys(margin_periods: margin_periods).each_with_object({}) do |date_keys, hash|
        hash[date_keys] = {}

        sorted_margins = applicable_margins.select { |m|
          m[:margin][:expiration_date] >= date_keys[:effective_date] &&
            m[:margin][:effective_date] <= date_keys[:expiration_date]
        }

        sorted_margins.sort_by! { |x| [x[:margin][:application_order], x[:rank], x[:priority]] }
        hash[date_keys] = sorted_margins
      end
    end

    def margins_to_apply
      @margins_to_apply = begin
        margin_periods = applicable_margins.group_by { |x| x[:margin].slice(:effective_date, :expiration_date) }
        if margin_periods.keys.length == 1
          margin_periods.values.first.sort_by! { |x| [x[:margin][:application_order], x[:rank], x[:priority]] }
          return margin_periods
        end

        final_margin_periods(margin_periods: margin_periods)
      end
    end

    def decorate_margins(target_hierarchy:, input_margins:)
      input_margins.map do |margin|
        hierarchy_data = target_hierarchy.find { |hier| hier[:data] == margin.applicable }
        rank = hierarchy_data ? hierarchy_data[:rank] : 0
        priority = hierarchy_data ? target_hierarchy.index(hierarchy_data) : 0
        { priority: priority, margin: margin, rank: rank }
      end
    end

    def pricings_to_return
      @pricings_to_return ||= if type == :freight_margin
        manipulate_freight_pricings
      elsif %i[trucking_pre_margin trucking_on_margin].include?(type)
        manipulate_trucking_pricings
      elsif %i[import_margin export_margin].include?(type)
        manipulate_local_charges
      end
    end

    def reset_flat_margins
      @flat_margins = Hash.new { |h, k| h[k] = [] }
    end

    def manipulate_freight_pricings
      margins_to_apply.map do |date_keys, data|
        fees = pricing.fees
        new_effective_date, new_expiration_date = manipulate_dates(pricing, date_keys)
        next if new_effective_date > new_expiration_date || fees.empty? || data.pluck(:margin).empty?

        manipulated_pricing = update_result_effective_periods(
          effective_date: new_effective_date,
          expiration_date: new_expiration_date
        )
        update_meta(manipulated_pricing)
        manipulated_freight_rates = manipulate_freight_rates(fees: fees, data: data)
        next if manipulated_freight_rates.empty?

        manipulated_pricing["data"] = manipulated_freight_rates
        adjusted_flat_margins = adjust_flat_margins_for_fees(margins: flat_margins)
        @result[:flat_margins] = adjusted_flat_margins
        final_handling(manipulated_pricing: manipulated_pricing)
      end
    end

    def manipulate_local_charges
      margins_to_apply.map do |date_keys, data|
        fees = local_charge.fees.deep_dup
        manipulated_pricing = local_charge.as_json
        update_meta(manipulated_pricing)
        fee_hash = manipulate_json_hash_fees(fee_hash: fees, data: data)
        new_effective_date, new_expiration_date = manipulate_dates(local_charge, date_keys)
        manipulated_pricing = update_result_effective_periods(
          effective_date: new_effective_date,
          expiration_date: new_expiration_date
        )
        next if new_effective_date > new_expiration_date
        next if fee_hash.empty?

        manipulated_pricing["fees"] = fee_hash
        @result[:flat_margins] = adjust_flat_margins_for_fees(margins: flat_margins)
        final_handling(manipulated_pricing: manipulated_pricing)
      end
    end

    def final_handling(manipulated_pricing:)
      @result[:result] = manipulated_pricing
      Pricings::ManipulatorResult.new(@result)
    end

    def manipulate_trucking_pricings
      margins_to_apply.map do |date_keys, data|
        manipulated_pricing = update_result_effective_periods(
          effective_date: date_keys[:effective_date],
          expiration_date: date_keys[:expiration_date]
        )
        update_meta(manipulated_pricing)

        manipulated_pricing["fees"] = manipulate_json_hash_fees(fee_hash: trucking_pricing.fees, data: data)
        manipulated_pricing["rates"] = manipulate_trucking_rates_array(
          rates: trucking_pricing.rates.deep_dup,
          data: data
        )
        @result[:flat_margins] = adjust_flat_margins_for_fees(margins: flat_margins)
        final_handling(manipulated_pricing: manipulated_pricing)
      end
    end

    def trucking_value_for_manipulation(result:, key:, range:)
      if result[key].present?
        result.slice(key)
      else
        {key => range}
      end
    end

    def manipulate_trucking_rates_array(rates:, data:)
      rates.each_with_object({}) do |(key, range), hash|
        adjusted_key = key.downcase
        data.each do |mdata|
          result = handle_manipulation(
            margin: mdata[:margin],
            charge_category: trucking_charge_category,
            fee_json: trucking_value_for_manipulation(result: hash, key: adjusted_key, range: range),
            fee_count: 1,
            fee_format: :trucking
          )

          hash.merge!(result)
        end
      end
    end

    def manipulate_freight_rates(fees:, data:)
      return {} if data.empty?

      fees.each_with_object({}) do |fee, hash|
        fee_json = fee.to_fee_hash
        fee_code = fee.fee_code.downcase
        next if fee_code.nil?

        data.each do |mdata|
          hash[fee_code] = handle_manipulation(
            margin: mdata[:margin],
            charge_category: fee.charge_category,
            fee_json: hash[fee_code] || fee_json.values.first,
            fee_count: fees.count
          )
        end
      end
    end

    def update_result_effective_periods(effective_date:, expiration_date:)
      manipulated_pricing = (pricing || local_charge || trucking_pricing).as_json
      manipulated_pricing["effective_date"] = effective_date
      manipulated_pricing["expiration_date"] = expiration_date
      manipulated_pricing
    end

    def update_meta_for_margin(margin_value:, fee_code:, margin_or_detail:, result:)
      return if margin_value.zero?

      @result[:breakdowns] << Pricings::ManipulatorBreakdown.new(
        source: margin_or_detail,
        delta: margin_value,
        data: result,
        charge_category: charge_category_lookup(fee_code: fee_code)
      )
    end

    def charge_category_lookup(fee_code:)
      @charge_category_lookup ||= {}
      lookup_fee_code = fee_code.downcase
      @charge_category_lookup[lookup_fee_code] ||=
        ::Legacy::ChargeCategory.from_code(code: lookup_fee_code, organization_id: organization.id)
    end

    def margin_target_name(applicable)
      if applicable.respond_to?(:name)
        applicable.try(:name)
      elsif applicable.respond_to?(:profile)
        applicable.profile&.full_name
      end
    end

    def update_meta(manipulated_pricing)
      reset_flat_margins
      @result = {
        result: manipulated_pricing,
        original: @pricing || @trucking_pricing || @local_charge,
        breakdowns: [],
        flat_margins: []
      }
    end

    def manipulate_json_hash_fees(fee_hash:, data:)
      fee_count = fee_hash.keys.count
      fee_hash.each_with_object({}) { |(key, fee), hash|
        adjusted_key = key.downcase
        charge_category = charge_category_lookup(fee_code: adjusted_key)

        data.each do |mdata|
          hash[adjusted_key] = handle_manipulation(
            margin: mdata[:margin],
            charge_category: charge_category,
            fee_json: hash[adjusted_key] || fee,
            fee_count: fee_count,
            fee_format: :json
          )
        end
      }
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
      when "%"
        apply_percentage(value: value, rate: rate)
      when "&"
        apply_absolute_value(value: value, rate: rate)
      end
    end

    def handle_total_margin(margin:, fee_key:, flat_margins:, total:)
      margin_key = total ? "total" : fee_key
      flat_margins[margin_key.downcase] << margin
    end

    def extract_margin_value_and_operator(margin:, fee_count:)
      {
        operator: margin.operator,
        value: margin.operator == "%" ? margin.value : margin.value / fee_count.to_d
      }
    end

    def calulate_result_json(operator_and_value:, fee_json:, fee_format: :regular)
      case fee_format
      when :json
        apply_json_fee_manipulation(
          operator: operator_and_value[:operator],
          value: operator_and_value[:value],
          fee: fee_json
        )
      when :trucking
        apply_trucking_rate_manipulation(
          operator: operator_and_value[:operator],
          value: operator_and_value[:value],
          rates: fee_json
        )
      when :regular
        apply_freight_manipulation(
          operator: operator_and_value[:operator],
          value: operator_and_value[:value],
          fee: fee_json
        )
      end
    end

    def handle_relative_and_absolute(operator_and_value:, margin:, fee_json:, fee_key:, fee_format: :regular)
      result_json = calulate_result_json(
        operator_and_value: operator_and_value,
        fee_json: fee_json,
        fee_format: fee_format
      )

      update_meta_for_margin(
        fee_code: fee_key.downcase,
        margin_value: operator_and_value[:value],
        margin_or_detail: margin,
        result: result_json
      )

      result_json
    end

    def handle_manipulation(margin:, charge_category:, fee_json:, fee_count:, fee_format: :regular)
      effective_margin = (margin.details.find_by(charge_category_id: charge_category.id) || margin)
      parent_margin = effective_margin == margin
      if effective_margin.operator == "+"
        handle_total_margin(
          margin: effective_margin,
          fee_key: charge_category.code,
          flat_margins: flat_margins,
          total: effective_margin == margin
        )
        return fee_json
      end

      operator_and_value = extract_margin_value_and_operator(
        margin: effective_margin,
        fee_count: parent_margin ? fee_count : 1
      )

      handle_relative_and_absolute(
        operator_and_value: operator_and_value,
        margin: effective_margin,
        fee_json: fee_json,
        fee_key: charge_category.code,
        fee_format: fee_format
      )
    end

    def apply_freight_manipulation(value:, operator:, fee:)
      new_fee = fee.dup
      new_fee = apply_to_rate_and_min(object: new_fee, value: value, operator: operator)
      return new_fee if fee["range"].blank?

      new_fee["range"] = fee["range"].map { |range|
        apply_to_rate_and_min(object: range, value: value, operator: operator)
      }

      new_fee
    end

    def apply_to_rate_and_min(object:, value:, operator:)
      %w[rate min].each do |target_key|
        if object[target_key]
          object[target_key] = determine_manipulation(rate: object[target_key].to_d, value: value, operator: operator)
        end
      end
      object
    end

    def apply_json_fee_manipulation(value:, operator:, fee:)
      new_fee = fee.dup.with_indifferent_access
      RATE_VALUE_KEYS.each do |k|
        new_fee[k] = determine_manipulation(rate: fee[k].to_d, value: value, operator: operator) if fee[k]
      end
      new_fee["key"] = fee.values_at("key", "code").first.downcase

      return new_fee if fee["range"].blank?

      new_fee["range"] = fee["range"].map { |range|
        range.except("name", "currency", "rate_basis", "max", "min").each_key do |rk|
          range[rk] = determine_manipulation(rate: range[rk].to_d, value: value, operator: operator) if range[rk]
        end
        range
      }

      new_fee
    end

    def apply_trucking_rate_manipulation(value:, operator:, rates:)
      rates.entries.each_with_object({}).each do |(key, range), hash|
        new_range = range.map { |rate|
          new_rate = rate.deep_dup
          value_key = RATE_VALUE_KEYS.find { |k| new_rate.dig("rate", k) }
          new_rate["rate"][value_key] = determine_manipulation(
            rate: rate.dig("rate", value_key).to_d,
            value: value,
            operator: operator
          )
          new_rate["min_value"] = determine_manipulation(rate: rate["min_value"].to_d, value: value, operator: operator)
          new_rate
        }

        hash[key] = new_range
      end
    end

    def apply_percentage(value:, rate:)
      return rate.to_d if value.zero?
      rate.to_d * (1 + value)
    end

    def apply_absolute_value(value:, rate:)
      rate.to_d + value
    end

    def adjust_flat_margins_for_fees(margins:)
      return {} if margins.empty?

      fee_keys.each_with_object(Hash.new { |h, k| h[k] = 0 }) do |key, hash|
        adjusted_key = key.downcase
        margins[adjusted_key].uniq.each do |margin|
          update_meta_for_margin(
            fee_code: adjusted_key,
            margin_value: margin.value,
            margin_or_detail: margin,
            result: { rate_basis: rate_basis_for_flat_margins(fee_code: adjusted_key) }
          )
          hash[adjusted_key] += margin.value
        end
        handle_shipment_total_margins(total_margins: margins["total"], key: adjusted_key, result: hash)
      end
    end

    def rate_basis_for_flat_margins(fee_code:)
      case type.to_s
      when /freight/
        @result[:result].dig("data", fee_code, "rate_basis")
      when /port/
        @result[:result].dig("fees", fee_code.upcase, "rate_basis")
      else
        @result[:result].dig("fees", fee_code, "rate_basis") ||
          @result[:result].dig("rates", 0, 1, 0, "rate")
      end
    end

    def handle_shipment_total_margins(total_margins:, key:, result:)
      total_margins.uniq.each do |total_margin|
        divided_margin_value = total_margin.value / (fee_keys.count * cargo_count)
        adjusted_key = key.include?("trucking") ? trucking_charge_category.code : key
        update_meta_for_margin(
          fee_code: adjusted_key,
          margin_value: divided_margin_value,
          margin_or_detail: total_margin,
          result: { rate_basis: rate_basis_for_flat_margins(fee_code: adjusted_key) }
        )
        result[key] += divided_margin_value
      end
      result
    end

    def fee_keys
      return trucking_pricing.fees.keys | [trucking_charge_category.code] if trucking_pricing.present?
      return local_charge.fees.keys if local_charge.present?
      return [] if pricing.blank?

      pricing.fees.joins(:charge_category)
        .where.not("charge_categories.code LIKE ? OR charge_categories.code LIKE ?", "%unknown%", "%included%")
        .pluck("charge_categories.code")
    end

    def find_dates(args:)
      @start_date = sanitize_date(args.dig(:dates, :start_date))
      @end_date = sanitize_date(args.dig(:dates, :end_date))
    end

    def sanitize_date(date)
      return date if date.blank?
      return date if date.is_a?(ActiveSupport::TimeWithZone) || date.is_a?(Date)

      DateTime.parse(date)
    end

    def freight_variables(args:)
      @schedules = args[:schedules]&.sort_by!(&:etd)
      find_dates(args: args)
      find_freight_pricing_and_margins(args: args)
      @origin_hub_id = itinerary.origin_hub_id
      @destination_hub_id = itinerary.destination_hub_id
    end

    def build_from_freight_pricing(pricing:)
      @pricing = pricing
      @margins = ::Pricings::Margin.for_dates(pricing.effective_date, pricing.expiration_date).where(margin_query_args)
      @tenant_vehicle_id = pricing.tenant_vehicle_id
      @cargo_class = pricing.cargo_class
      @itinerary = pricing.itinerary
      assign_default_margin(default_for: pricing&.mode_of_transport)
    end

    def build_from_freight_attributes(args:)
      @itinerary = ::Legacy::Itinerary.find_by(id: args[:itinerary_id])
      @pricing = @itinerary&.rates&.for_dates(start_date, end_date)&.find_by(
        args.slice(:tenant_vehicle_id, :cargo_class, :itinerary_id).merge(
          organization_id: @organization.id
        )
      )
      @tenant_vehicle_id = args[:tenant_vehicle_id]
      @cargo_class = args[:cargo_class]
      find_margins(default_for: itinerary.mode_of_transport)
    end

    def margin_query_args
      {
        margin_type: type,
        organization_id: organization.id,
        default_for: nil
      }
    end

    def find_freight_pricing_and_margins(args:)
      if args[:pricing]
        build_from_freight_pricing(pricing: args[:pricing])
      else
        build_from_freight_attributes(args: args)
      end
    end

    def find_margins(default_for:)
      @margins = ::Pricings::Margin.where(margin_query_args).for_dates(start_date, end_date)
      assign_default_margin(default_for: default_for)
    end

    def trucking_variables(args:)
      find_dates(args: args)
      @trucking_pricing = args[:trucking_pricing]
      is_pre_carriage = type == :trucking_pre_margin
      @cargo_class = trucking_pricing.cargo_class
      @trucking_charge_category = ::Legacy::ChargeCategory.from_code(
        code: "trucking_#{cargo_class}",
        organization_id: Organizations.current_id
      )
      if is_pre_carriage
        @destination_hub_id = trucking_pricing.hub_id
      else
        @origin_hub_id = trucking_pricing.hub_id
      end
      @tenant_vehicle_id = trucking_pricing.tenant_vehicle_id
      find_margins(default_for: "trucking")
    end

    def local_charge_variables(args:)
      @schedules = args[:schedules]&.sort_by!(&:etd)
      @local_charge = args[:local_charge]
      @cargo_class = local_charge.load_type
      @counterpart_hub_id = local_charge.counterpart_hub_id
      if @type == :import_margin
        @destination_hub_id = local_charge.hub_id
      else
        @origin_hub_id = local_charge.hub_id
      end
      @tenant_vehicle_id = local_charge.tenant_vehicle_id
      find_dates(args: args)
      find_margins(default_for: "local_charge")
    end

    def assign_default_margin(default_for:)
      @default_margin = Pricings::Margin.find_by(
        margin_type: type,
        organization_id: organization.id,
        applicable: organization,
        default_for: default_for
      )
    end

    private

    attr_reader :target, :organization, :scope, :shipment, :cargo_unit_id, :meta, :type,
      :default_margin, :itinerary,
      :origin_hub_id, :destination_hub_id, :tenant_vehicle_id, :cargo_class, :pricing, :end_date,
      :local_charge, :margins, :trucking_pricing, :trucking_charge_category, :direction, :schedules,
      :start_date, :counterpart_hub_id, :metadata_list, :flat_margins, :cargo_count
  end
end
