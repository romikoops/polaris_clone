# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurers
    class SacoShipping < Base # rubocop:disable Metrics/ClassLength
      ROW_IDENTIFIER_KEYS = %i(
        sheet_name
        data_restructurer_name
        destination_country
        destination_hub
        origin_hub
        transshipment_via
        carrier
      ).freeze

      LOCAL_CHARGES_GROUPING_KEYS = %i(
        carrier
        effective_date
        expiration_date
        mot
        load_type
        hub
        country
        counterpart_hub
        counterpart_country
        direction
      ).freeze

      STANDARD_OCEAN_FREIGHT_FEE_CODE = 'BAS'

      def perform # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        sheet_name = data[:sheet_name]
        data_restructurer_name = data[:data_restructurer_name]
        restructured_data = replace_nil_equivalents_with_nil(data[:rows_data])

        restructured_data = restructured_data.map do |row_data|
          { sheet_name: sheet_name,
            data_restructurer_name: data_restructurer_name }.merge(row_data)
        end

        # Throw away [internal data, remarks and transshipment]
        # TODO: Use the data!
        internal_keys = restructured_data.first.keys.select { |k| k.to_s.starts_with?('int/') }
        restructured_data.each do |row_data|
          row_data.except!(*internal_keys, :remarks, :transshipment_via)
        end

        restructured_data = expand_to_multiple(restructured_data)

        restructured_data.each do |single_data|
          klass_identifier =
            ExcelDataServices::DataRestructurers::InsertionTypeDetector.detect(single_data, data_restructurer_name)
          single_data[:klass_identifier] = klass_identifier
        end

        restructured_data = expand_fcl_to_all_sizes(restructured_data) # TODO: Really necessary?

        restructured_data_pricings, restructured_data_local_charges =
          restructured_data.partition { |row_data| row_data[:klass_identifier] == 'Pricing' }

        restructured_data_pricings.each { |row_data| row_data.delete(:direction) }
        restructured_data_pricings = add_hub_names(restructured_data_pricings)

        # Necessary until we get rid of structure "one pricing<->many pricing_details"
        restructured_data_pricings = group_by_pricing_params(restructured_data_pricings)

        restructured_data_local_charges = pricings_format_to_local_charges_format(restructured_data_local_charges)

        { 'Pricing' => restructured_data_pricings,
          'LocalCharges' => restructured_data_local_charges }
      end

      private

      def expand_to_multiple(rows_data)
        rows_data.flat_map do |row_data|
          multiple_objs = expand_based_on_fee_containing_column(row_data)
          multiple_objs = expand_based_on_effective_period(multiple_objs)
          multiple_objs = expand_based_on_type_of_fee(multiple_objs)
          multiple_objs = adapt_origin_destination(multiple_objs)
          multiple_objs = expand_based_on_preliminary_load_type(multiple_objs)
          multiple_objs.uniq
        end
      end

      def expand_based_on_fee_containing_column(row_data) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        restructured_data = []

        same_for_all_fees = row_data.slice(*ROW_IDENTIFIER_KEYS).merge(
          mot: 'ocean',
          rate_basis: 'PER_CONTAINER'
        )
        row_nr = row_data.delete(:row_nr)
        whole_row_effective_date = Date.parse(row_data.delete(:effective_date).to_s)
        whole_row_expiration_date = Date.parse(row_data.delete(:expiration_date).to_s)
        rest = row_data.except(*ROW_IDENTIFIER_KEYS)

        rest.each do |key, value|
          col_name = key.to_s
          next if value.blank? || col_name[/_month/]

          if col_name[/(curr|next)/]
            effective_date, expiration_date = determine_correct_effective_period(
              col_name, row_data, whole_row_effective_date, whole_row_expiration_date
            )
          else
            effective_date = whole_row_effective_date
            expiration_date = whole_row_expiration_date
          end

          restructured_single_data = same_for_all_fees.merge(
            key => value,
            effective_date: effective_date,
            expiration_date: expiration_date,
            row_nr: row_nr
          )

          direction_key = col_name.scan(/imp|exp/).first
          if direction_key
            direction = { 'imp' => 'import',
                          'exp' => 'export' }[direction_key]
            restructured_single_data[:direction] = direction
          end

          restructured_data << restructured_single_data
        end

        restructured_data
      end

      def expand_based_on_effective_period(multiple_objs) # rubocop:disable Metrics/AbcSize
        effective_periods = multiple_objs.map { |row_data| row_data.values_at(:effective_date, :expiration_date) }.uniq
        return multiple_objs if effective_periods.size == 1

        effective_periods.sort_by! { |date| date.second - date.first }
        longest_period = effective_periods.last
        shorter_periods = effective_periods[0...-1]
        first_date_in_shorter_periods = shorter_periods.map(&:first).min
        last_date_in_shorter_periods = shorter_periods.map(&:second).max

        if longest_period.first > first_date_in_shorter_periods || longest_period.second < last_date_in_shorter_periods
          raise "Some effective month values are out outside of #{longest_period}"
        end

        objs_with_longest_period, objs_with_shorter_period = multiple_objs.partition do |row_data|
          row_data.values_at(:effective_date, :expiration_date) == longest_period
        end

        expanded_objs_with_longest_period = objs_with_longest_period.flat_map do |row_data|
          shorter_periods.map do |effective_date, expiration_date|
            row_data.merge(effective_date: effective_date, expiration_date: expiration_date)
          end
        end

        objs_with_shorter_period + expanded_objs_with_longest_period
      end

      def determine_correct_effective_period(col_name, row_data, effective_date, expiration_date)
        corresponding_month_key = col_name.sub(/(curr|next)/, '\1_month').to_sym
        effective_month = row_data[corresponding_month_key]

        if effective_month && !effective_month[/-|incl/]
          month_year = Date.parse("#{effective_month} #{effective_date.year}")
          month_year = Date.parse("#{effective_month} #{expiration_date.year}") if month_year < effective_date
          effective_date = month_year
          expiration_date = month_year.next_month - 1.day
        end

        [effective_date, expiration_date]
      end

      def expand_based_on_type_of_fee(multiple_objs) # rubocop:disable MethodLength
        multiple_objs = multiple_objs.map do |row_data| # rubocop:disable Metrics/BlockLength
          additional_keys_same_for_all = %i(
            row_nr
            effective_date
            expiration_date
            mot
            rate_basis
            direction
          )
          same_for_all_fees = row_data.slice(*ROW_IDENTIFIER_KEYS, *additional_keys_same_for_all)
          fee_column_data = row_data.except(*ROW_IDENTIFIER_KEYS, *additional_keys_same_for_all)

          fee_column_key, fee_column_value = fee_column_data.first
          fee_is_included = fee_is_included?(fee_column_value)

          preliminary_load_type = determine_preliminary_load_type(fee_column_key)
          fee_code, fee_name = determine_fee_naming_components(
            fee_column_key, preliminary_load_type, fee_is_included
          )
          currency, fee = determine_fee_value_components(fee_is_included, fee_column_value)

          next unless fee.present?

          same_for_all_fees.merge(
            preliminary_load_type: preliminary_load_type,
            fee_code: fee_code,
            fee_name: fee_name,
            currency: currency,
            fee: fee,
            fee_min: fee
          )
        end

        multiple_objs.compact
      end

      def determine_preliminary_load_type(key)
        pure_size_class = determine_pure_size_class(key.to_s)
        "fcl_#{pure_size_class.remove('_dc')}".downcase if pure_size_class
      end

      def determine_pure_size_class(str)
        pure_size_class = str.scan(/(20_?(dc)?|40_?(dc|hq)?)/).dig(0, 0)
        pure_size_class&.sub(/_*(dc|hq)/, '_\1')
      end

      def determine_fee_naming_components(fee_column_key, preliminary_load_type, fee_is_included)
        key_parts = fee_column_key.to_s.split('/')
        case key_parts.size
        when 1
          fee_code = preliminary_load_type ? STANDARD_OCEAN_FREIGHT_FEE_CODE : key_parts.first.upcase
          fee_name = fee_code.titleize
        when 2
          fee_code = key_parts.second.upcase
          fee_name = fee_code.titleize
        when 3
          fee_code = key_parts.third.upcase
          fee_name = fee_code.titleize
        end

        if fee_is_included
          fee_code = "UNKNOWN_#{fee_code}"
          fee_name = "#{fee_name} (included)"
        end

        [fee_code, fee_name]
      end

      def determine_fee_value_components(fee_is_included, fee_column_value)
        if fee_is_included
          currency = nil
          fee = 0
        else
          currency = Monetize.parse(fee_column_value).currency.to_s
          fee = fee_column_value.delete('^0-9').to_i # this regex only works correctly for integer fee values!
        end

        [currency, fee]
      end

      def fee_is_included?(value)
        value[/incl/i]
      end

      def adapt_origin_destination(multiple_objs)
        multiple_objs.map do |row_data|
          origin_hub = row_data.delete(:origin_hub)
          origin_hub = determine_location_name_from_locode(origin_hub)
          destination_hub = row_data.delete(:destination_hub)
          destination_country = row_data.delete(:destination_country)
          row_data[:origin] = origin_hub
          row_data[:country_origin] = nil
          row_data[:destination] = destination_hub
          row_data[:country_destination] = destination_country
          row_data
        end
      end

      def expand_based_on_preliminary_load_type(multiple_objs)
        multiple_objs.flat_map do |row_data|
          preliminary_load_type = row_data.delete(:preliminary_load_type)
          determine_actual_load_types(preliminary_load_type).map do |load_type|
            row_data.merge(load_type: load_type)
          end
        end
      end

      def determine_actual_load_types(preliminary_load_type)
        if preliminary_load_type
          [preliminary_load_type]
        else
          Container::CARGO_CLASSES.map(&:downcase)
        end
      end

      def pricings_format_to_local_charges_format(rows_data)
        rows_data = adapt_for_local_charges_format(rows_data)
        grouped_data = rows_data.group_by { |row_data| row_data.slice(*LOCAL_CHARGES_GROUPING_KEYS) }.values

        grouped_data.map do |group|
          same_for_all_in_group = group.first.slice(
            *LOCAL_CHARGES_GROUPING_KEYS,
            :service_level,
            :hub_name,
            :counterpart_hub_name
          )
          row_nrs = group.map { |row_data| row_data[:row_nr] }.join(', ')

          fees = {}
          group.each do |row_data|
            fee_code = row_data[:fee_code]
            rate_basis = RateBasis.get_internal_key(row_data[:rate_basis].upcase)
            fee = { fee_code => { currency: row_data[:currency],
                                  key: fee_code,
                                  min: row_data[:fee_min],
                                  max: nil,
                                  name: row_data[:fee_name],
                                  rate_basis: rate_basis,
                                  **specific_charge_params(rate_basis, row_data) } }

            fees.merge!(fee)
          end

          same_for_all_in_group.merge(fees: fees).merge(row_nr: row_nrs)
        end
      end

      def adapt_for_local_charges_format(rows_data)
        rows_data.each do |row_data|
          row_data[:service_level] = 'standard'
          row_data[:load_type] = row_data[:load_type].downcase
          row_data[:hub] = row_data.delete(:origin)
          row_data[:hub_name] = append_hub_suffix(row_data[:hub], row_data[:mot])
          row_data[:country] = row_data.delete(:country_origin)
          row_data[:counterpart_hub] = row_data.delete(:destination)
          row_data[:counterpart_hub_name] = append_hub_suffix(row_data[:counterpart_hub], row_data[:mot])
          row_data[:counterpart_country] = row_data.delete(:country_destination)
        end

        rows_data
      end

      def specific_charge_params(rate_basis, single_data)
        # This is just a slimmed-down version of the similar method in the pure local_charges restructurer
        case rate_basis
        when 'PER_CONTAINER'
          { value: single_data[:fee] }
        end
      end
    end
  end
end
