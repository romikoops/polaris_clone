# frozen_string_literal: true

module Pricings
  class Manipulator # rubocop:disable Metrics/ClassLength
    MissingArgument = Class.new(StandardError)
    TRUCKING_QUERY_DAYS = 10

    def initialize(type:, target:, organization:, args:)
      argument_errors(type, target, args)
      @type = type
      @target = target || Groups::Group.find_by(name: 'default', organization: organization)
      @organization = organization
      @scope = OrganizationManager::ScopeService.new(target: target, organization: organization).fetch
      @sandbox = args[:sandbox]
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
      @metadata_list = []
    end

    def perform
      @applicable_margins = find_applicable_margins
      @margins_to_apply = sort_margins
      manipulate_pricings
      
      [pricings_to_return.compact, metadata_list]
    end

    def find_applicable_margins
      hierarchy = OrganizationManager::HierarchyService.new(target: target, organization: organization).fetch
      target_hierarchy = hierarchy.reverse.reject { |hier| hier == organization }
                                  .map.with_index { |hier, i| { rank: i, data: hier } }
      all_margins = apply_hierarchy(hierarchy: target_hierarchy)

      return all_margins unless all_margins.empty?

      organization_hierarchy = [
        { rank: 0, data: [organization] }
      ]

      apply_hierarchy(hierarchy: organization_hierarchy, for_organization: true)
    end

    def apply_hierarchy(hierarchy:, for_organization: false)
      return [] if hierarchy.empty?

      permutations = margin_params.product(hierarchy)
      base_args, base_target = permutations.first
      base_query = margins.where(base_args.merge(applicable: base_target[:data]))

      margin_relation = permutations.drop(1).inject(base_query) do |query, (args, hier)|
        next query unless margins.exists?(args.merge(applicable: hier[:data]))

        query.or(margins.where(args.merge(applicable: hier[:data])))
      end

      all_margins = decorate_margins(target_margins: margin_relation.distinct.to_a, target_hierarchy: hierarchy)
      handle_default_margin(margins: all_margins, for_organization: for_organization)
    end

    def handle_default_margin(margins:, for_organization:)
      return margins if default_margin.blank?

      not_empty_non_dedicated = scope[:dedicated_pricings_only].blank? && !margins.empty?
      for_organization_and_empty = for_organization && margins.empty?
      margins << { priority: 0, margin: default_margin, rank: 0 } if not_empty_non_dedicated || for_organization_and_empty
      margins
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
      ).map do |product|
        {
          organization_id: organization.id,
          itinerary_id: product[0],
          origin_hub_id: product[1],
          destination_hub_id: product[2],
          tenant_vehicle_id: product[3],
          cargo_class: product[4],
          pricing_id: product[5]
        }
      end

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
      result_date_keys = date_keys.map.with_index do |date, i|
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
      end
      result_date_keys.compact
    end

    def final_margin_periods(margin_periods:)
      adjusted_date_keys(margin_periods: margin_periods).each_with_object({}) do |date_keys, hash|
        hash[date_keys] = {}

        sorted_margins = applicable_margins.select do |m|
          m[:margin][:expiration_date] >= date_keys[:effective_date] &&
            m[:margin][:effective_date] <= date_keys[:expiration_date]
        end

        sorted_margins.sort_by! { |x| [x[:margin][:application_order], x[:rank], x[:priority]] }
        hash[date_keys] = sorted_margins
      end
    end

    def sort_margins
      margin_periods = applicable_margins.group_by { |x| x[:margin].slice(:effective_date, :expiration_date) }
      if margin_periods.keys.length == 1
        margin_periods.values.first.sort_by! { |x| [x[:margin][:application_order], x[:rank], x[:priority]] }
        return margin_periods
      end

      final_margin_periods(margin_periods: margin_periods)
    end

    def decorate_margins(target_margins:, target_hierarchy:)
      target_margins.map do |margin|
        priority = target.is_a?(::Tenants::Membership) ? margin.priority : 0
        hierarchy_data = target_hierarchy.find { |hier| hier[:data] == margin.applicable }
        rank = hierarchy_data ? hierarchy_data[:rank] : 0

        { priority: priority, margin: margin, rank: rank }
      end
    end

    def manipulate_pricings
      if type == :freight_margin
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
      @pricings_to_return = margins_to_apply.map do |date_keys, data|
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

        manipulated_pricing['data'] = manipulated_freight_rates
        adjusted_flat_margins = adjust_flat_margins_for_fees(margins: flat_margins)
        manipulated_pricing['flat_margins'] = adjusted_flat_margins
        final_handling(manipulated_pricing: manipulated_pricing)
      end
    end

    def manipulate_local_charges
      @pricings_to_return = margins_to_apply.map do |date_keys, data|
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

        manipulated_pricing['fees'] = fee_hash
        manipulated_pricing['flat_margins'] = adjust_flat_margins_for_fees(margins: flat_margins)
        final_handling(manipulated_pricing: manipulated_pricing)
      end
    end

    def final_handling(manipulated_pricing:)
      manipulated_pricing['metadata_id'] = meta[:metadata_id]
      metadata_list << meta
      manipulated_pricing.with_indifferent_access
    end

    def manipulate_trucking_pricings
      @pricings_to_return = margins_to_apply.map do |date_keys, data|
        manipulated_pricing = update_result_effective_periods(
          effective_date: date_keys[:effective_date],
          expiration_date: date_keys[:expiration_date]
        )
        update_meta(manipulated_pricing)

        manipulated_pricing['fees'] = manipulate_json_hash_fees(fee_hash: trucking_pricing.fees, data: data)
        manipulated_pricing['rates'] = manipulate_trucking_rates_array(
          rates: trucking_pricing.rates.deep_dup,
          data: data
        )
        manipulated_pricing['flat_margins'] = adjust_flat_margins_for_fees(margins: flat_margins)
        final_handling(manipulated_pricing: manipulated_pricing)
      end
    end

    def trucking_value_for_manipulation(result:, key:, range:)
      if result[key].present?
        result.slice(key)
      else
        { key => range }
      end
    end

    def manipulate_trucking_rates_array(rates:, data:)
      rates.each_with_object({}) do |(key, range), hash|
        adjusted_key = key.downcase
        data.each do |mdata|
          result = handle_manipulation(
            margin: mdata[:margin],
            charge_category: metadata_charge_category,
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
      manipulated_pricing['effective_date'] =  effective_date
      manipulated_pricing['expiration_date'] = expiration_date
      manipulated_pricing
    end

    def update_meta_for_margin(margin_value:, fee_code:, margin_or_detail:, result:)
      return if margin_value.zero?

      parent_margin = margin_or_detail
      parent_margin = margin_or_detail.margin if margin_or_detail.is_a?(Pricings::Detail)

      meta[:fees][fee_code.to_sym][:breakdowns].push(
        source_id: margin_or_detail.id,
        source_type: margin_or_detail.class.to_s,
        margin_value: margin_value,
        operator: margin_or_detail.operator,
        margin_target_type: parent_margin.applicable_type,
        margin_target_id: parent_margin.applicable_id,
        margin_target_name: margin_target_name(parent_margin.applicable),
        adjusted_rate: result
      )
    end

    def margin_target_name(applicable)
      return applicable.try(:name) unless applicable.is_a?(Organizations::User)

      Profiles::ProfileService.fetch(user_id: applicable.id)&.full_name
    end

    def update_meta(manipulated_pricing)
      meta_id = SecureRandom.uuid
      @meta = {
        fees: Hash.new { |h, k| h[k] = { breakdowns: [], metadata: {} } },
        pricing_id: manipulated_pricing['id'],
        cargo_class: @cargo_class,
        metadata_id: meta_id
      }
      meta[:cargo_unit_id] = cargo_unit_id if cargo_unit_id.present?
      reset_flat_margins
      if pricing.present?
        update_freight_meta
      elsif trucking_pricing.present?
        update_trucking_meta
      else
        update_json_fee_meta
      end
      meta[:direction] = direction if pricing.blank?
    end

    def update_freight_meta
      pricing.fees.each do |fee|
        next unless meta[:fees][fee.fee_code.to_sym][:breakdowns].empty?

        meta[:fees][fee.fee_code.to_sym][:breakdowns] << { adjusted_rate: fee.fee_data }
        meta[:fees][fee.fee_code.to_sym][:metadata] = fee.metadata
      end
    end

    def update_json_fee_meta
      meta[:direction] = direction
      target = local_charge || trucking_pricing
      target.fees.each do |fee_key, fee|
        meta_key = fee_key.downcase.to_sym
        next unless meta[:fees][meta_key][:breakdowns].empty?

        meta[:fees][meta_key][:breakdowns] << { adjusted_rate: fee }
        meta[:fees][meta_key][:metadata] = target.metadata
      end
    end

    def update_trucking_meta
      update_json_fee_meta
      update_trucking_rate_meta
    end

    def update_trucking_rate_meta
      meta[:fees][metadata_charge_category.code.to_sym][:breakdowns] << { adjusted_rate: trucking_pricing.rates }
      meta[:fees][metadata_charge_category.code.to_sym][:metadata] = trucking_pricing.metadata
    end

    def manipulate_json_hash_fees(fee_hash:, data:)
      fee_count = fee_hash.keys.count
      result = fee_hash.each_with_object({}) do |(key, fee), hash|
        adjusted_key = key.downcase
        charge_category = ::Legacy::ChargeCategory.find_by(code: adjusted_key, organization: organization.id)

        data.each do |mdata|
          hash[adjusted_key] = handle_manipulation(
            margin: mdata[:margin],
            charge_category: charge_category,
            fee_json: hash[adjusted_key] || fee,
            fee_count: fee_count,
            fee_format: :json
          )
        end
      end
      result
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
      when '&'
        apply_absolute_value(value: value, rate: rate)
      end
    end

    def handle_total_margin(margin:, fee_key:, flat_margins:, total:)
      margin_key = total ? 'total' : fee_key
      flat_margins[margin_key.downcase] << margin
    end

    def extract_margin_value_and_operator(margin:, fee_count:)
      {
        operator: margin.operator,
        value: margin.operator == '%' ? margin.value : margin.value / fee_count.to_d
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
      if effective_margin.operator == '+'
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
      return new_fee if fee['range'].blank?

      new_fee['range'] = fee['range'].map do |range|
        apply_to_rate_and_min(object: range, value: value, operator: operator)
      end

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
      only_values = fee.except('name', 'key', 'currency', 'rate_basis', 'range', 'effective_date', 'expiration_date')
      only_values.keys.each do |k|
        new_fee[k] = determine_manipulation(rate: fee[k].to_d, value: value, operator: operator) if fee[k]
      end
      new_fee['key'] = fee['key'].downcase

      return new_fee if fee['range'].blank?

      new_fee['range'] = fee['range'].map do |range|
        range.except('name', 'currency', 'rate_basis', 'max', 'min').keys.each do |rk|
          range[rk] = determine_manipulation(rate: range[rk].to_d, value: value, operator: operator) if range[rk]
        end
        range
      end

      new_fee
    end

    def apply_trucking_rate_manipulation(value:, operator:, rates:)
      rates.entries.each_with_object({}).each do |(key, range), hash|
        new_range = range.map do |rate|
          new_rate = rate.deep_dup
          new_rate['rate']['value'] = determine_manipulation(
            rate: rate['rate']['value'].to_d,
            value: value,
            operator: operator
          )
          new_rate['min_value'] = determine_manipulation(rate: rate['min_value'].to_d, value: value, operator: operator)
          new_rate
        end

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
            result: {}
          )
          hash[adjusted_key] += margin.value
        end
        handle_shipment_total_margins(total_margins: margins['total'], key: adjusted_key, result: hash)
      end
    end

    def handle_shipment_total_margins(total_margins:, key:, result:)
      total_margins.uniq.each do |total_margin|
        divided_margin_value = total_margin.value / (fee_keys.count * cargo_count)

        update_meta_for_margin(
          fee_code: key.include?('trucking') ? metadata_charge_category.code : key,
          margin_value: divided_margin_value,
          margin_or_detail: total_margin,
          result: {}
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
             .where.not('charge_categories.code LIKE ? OR charge_categories.code LIKE ?', '%unknown%', '%included%')
             .pluck('charge_categories.code')
    end

    def find_dates(args:)
      case type
      when :freight_margin
        freight_dates
      when :trucking_pre_margin, :trucking_on_margin
        trucking_dates(args: args)
      else
        local_charge_dates
      end
    end

    def sanitize_date(date)
      return date if date.blank?
      return date if date.is_a?(ActiveSupport::TimeWithZone) || date.is_a?(Date)

      DateTime.parse(date)
    end

    def freight_dates
      @start_date = sanitize_date(schedules.first.etd)
      @end_date = sanitize_date(schedules.last.etd)
      @end_date += 10.days if schedules.last.etd == schedules.first.etd
    end

    def trucking_dates(args:)
      @start_date = sanitize_date(args[:date])
      @end_date = sanitize_date(args[:date]) + TRUCKING_QUERY_DAYS.days
    end

    def local_charge_dates
      @start_date = sanitize_date(schedules.first.etd) || Time.zone.today + 4.days
      @end_date = sanitize_date(schedules.last.eta) || Time.zone.today + 24.days
    end

    def freight_variables(args:)
      @schedules = args[:schedules]&.sort_by!(&:etd)
      find_dates(args: args)
      find_freight_pricing_and_margins(args: args)
      @origin_hub_id = itinerary.ordered_hub_ids.first
      @destination_hub_id = itinerary.ordered_hub_ids.last
      @pricing_to_return = pricing&.as_json
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
      @pricing =   @itinerary&.rates&.for_dates(start_date, end_date)&.find_by(
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
        sandbox: sandbox,
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
      is_pre_carriage =  type == :trucking_pre_margin
      @trucking_charge_category = ::Legacy::ChargeCategory.from_code(
        organization_id: organization.id,
        code: "trucking_#{is_pre_carriage ? 'pre' : 'on'}"
      )
      @cargo_class = trucking_pricing.cargo_class
      @direction = is_pre_carriage ? 'export' : 'import'
      if is_pre_carriage
        @destination_hub_id = trucking_pricing.hub_id
      else
        @origin_hub_id = trucking_pricing.hub_id
      end
      @metadata_charge_category = ::Legacy::ChargeCategory.from_code(
        code: "trucking_#{cargo_class}",
        organization_id: trucking_pricing.organization_id,
        sandbox: sandbox
      )
      find_margins(default_for: 'trucking')
    end

    def local_charge_variables(args:)
      @schedules = args[:schedules]&.sort_by!(&:etd)
      @local_charge = args[:local_charge]
      @cargo_class = local_charge.load_type
      @direction = local_charge.direction
      @counterpart_hub_id = local_charge.counterpart_hub_id
      if @type == :import_margin
        @destination_hub_id = local_charge.hub_id
      else
        @origin_hub_id = local_charge.hub_id
      end
      @tenant_vehicle_id = local_charge.tenant_vehicle_id
      find_dates(args: args)
      find_margins(default_for: 'local_charge')
    end

    def assign_default_margin(default_for:)
      @default_margin = Pricings::Margin.find_by(
        margin_type: type,
        organization_id: organization.id,
        applicable: organization,
        sandbox: sandbox,
        default_for: default_for
      )
    end

    def argument_errors(type, target, args)
      return if (args[:schedules].present? && type == :freight_margin) || type != :freight_margin

      raise Pricings::Manipulator::MissingArgument
    end

    private

    attr_reader :target, :organization, :scope, :shipment, :sandbox, :cargo_unit_id, :meta, :type,
                :applicable_margins, :margins_to_apply, :pricings_to_return, :default_margin, :itinerary,
                :origin_hub_id, :destination_hub_id, :tenant_vehicle_id, :cargo_class, :pricing, :end_date,
                :local_charge, :margins, :trucking_pricing, :trucking_charge_category, :direction, :schedules,
                :start_date, :pricing_to_return, :counterpart_hub_id, :metadata_list, :metadata_charge_category,
                :flat_margins, :cargo_count
  end
end
