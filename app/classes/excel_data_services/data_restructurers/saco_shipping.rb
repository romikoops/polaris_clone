# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurers
    class SacoShipping < Base # rubocop:disable Metrics/ClassLength
      TREAT_AS_NOTE_COLUMNS = %i(
        remarks
        transshipment_via
      ).freeze

      ROW_IDENTIFIER_KEYS = %i(
        sheet_name
        data_restructurer_name
        internal
        destination_country
        destination_hub
        destination_locode
        origin_hub
        origin_locode
        carrier
      ).freeze

      ADDITIONAL_KEYS_SAME_FOR_ALL = %i(
        effective_date
        expiration_date
        mot
        rate_basis
        row_nr
      ).freeze

      LOCAL_CHARGES_GROUPING_KEYS = %i(
        internal
        direction
        mot
        load_type
        carrier
        effective_date
        expiration_date
        country
        hub
        hub_locode
        counterpart_country
        counterpart_hub
        counterpart_hub_locode
      ).freeze

      CONTAINER_CLASSES_LOOKUP = {
        'fcl_20' => %w(fcl_20),
        'fcl_40' => %w(fcl_40 fcl_40_hq)
      }.freeze

      OCEAN_FREIGHT_COLUMNS = %w(20dc 40dc 40hq).freeze

      STANDARD_OCEAN_FREIGHT_FEE_CODE = 'BAS'

      MONTHS_GERMAN_TO_ENGLISH_LOOKUP = {
        'MAI' => 'MAY',
        'OKT' => 'OCT',
        'DEZ' => 'DEC'
      }.freeze

      def initialize(tenant:, data:)
        super
        @restructured_data = nil # TODO: Transfer this to base class
      end

      def perform
        @restructured_data = rows_data_with_meta_information
        treat_some_columns_as_notes
        ignore_data_with_int_prefix
        replace_nil_equivalents_with_nil(restructured_data) # TODO: change method to use instance variable
        correctly_mark_internal_row_data
        replace_blank_with_false_for_internal_flag
        clean_html_format_artifacts(restructured_data) # TODO: change method to use instance variable
        combine_terminal_and_destination
        @restructured_data = expand_to_multiple

        restructured_data_pricings, restructured_data_local_charges =
          restructured_data.partition { |row_data| row_data.delete(:klass_identifier) == 'Pricing' }
        restructured_data_pricings = expand_based_on_date_overlaps(
          restructured_data_pricings,
          ROWS_BY_PRICING_PARAMS_GROUPING_KEYS - %i(effective_date expiration_date)
        )
        restructured_data_pricings = group_by_params(restructured_data_pricings, ROWS_BY_PRICING_PARAMS_GROUPING_KEYS)
        restructured_data_local_charges = adapt_for_direction(restructured_data_local_charges)
        restructured_data_local_charges = expand_based_on_date_overlaps(
          restructured_data_local_charges,
          LOCAL_CHARGES_GROUPING_KEYS - %i(effective_date expiration_date)
        )
        restructured_data_local_charges = pricings_format_to_local_charges_format(restructured_data_local_charges)

        { 'Pricing' => restructured_data_pricings,
          'LocalCharges' => restructured_data_local_charges }
      end

      private

      attr_reader :restructured_data

      def rows_data_with_meta_information
        data[:rows_data].map do |row_data|
          new_row_data = row_data.dup
          new_row_data[:sheet_name] = data[:sheet_name]
          new_row_data[:data_restructurer_name] = data[:data_restructurer_name]
          new_row_data
        end
      end

      def treat_some_columns_as_notes
        restructured_data.each do |row_data|
          TREAT_AS_NOTE_COLUMNS.each do |col_name|
            row_data[:"note/#{col_name}"] = row_data.delete(col_name)
          end
        end
      end

      def ignore_data_with_int_prefix
        internal_keys = restructured_data.first.keys.select { |k| k.to_s.starts_with?('int/') }
        restructured_data.each { |row_data| row_data.except!(*internal_keys) }
      end

      def replace_blank_with_false_for_internal_flag
        restructured_data.each do |row_data|
          row_data[:internal] = false if row_data[:internal].blank?
        end
      end

      def expand_to_multiple
        note_keys = restructured_data.first.keys.select { |k| k.to_s.starts_with?('note/') }
        restructured_data.flat_map do |row_data|
          multiple_objs = expand_based_on_fee_containing_column(row_data)
          multiple_objs = expand_based_on_type_of_fee(multiple_objs)
          multiple_objs = expand_based_on_preliminary_load_type(multiple_objs)
          notes = extract_notes(row_data, note_keys)
          add_notes_to_pricings(multiple_objs, notes)
          adapt_origin_destination(multiple_objs)
          multiple_objs.uniq
        end
      end

      def combine_terminal_and_destination
        restructured_data.each do |row_data|
          row_data[:destination_hub] = [row_data[:destination_hub], row_data.delete(:terminal)].compact.join(' - ')
        end
      end

      def correctly_mark_internal_row_data
        restructured_data.each { |row_data| row_data[:internal] = row_data[:internal].to_s.casecmp?('x') }
      end

      def expand_based_on_fee_containing_column(row_data)
        row_nr = row_data.delete(:row_nr)
        same_for_all_fees = row_data.slice(*ROW_IDENTIFIER_KEYS)

        full_effective_date = Date.parse(row_data.delete(:effective_date).to_s)
        full_expiration_date = Date.parse(row_data.delete(:expiration_date).to_s)

        # Map the data that is not the same for all fees and combine each object with the data that is the same for all
        multiple_objs = row_data.except(*ROW_IDENTIFIER_KEYS).map do |key, value|
          col_name = key.to_s
          next if value.blank? || col_name.starts_with?('note/') || col_name.match?(/curr_month|next_month/)

          effective_date, expiration_date =
            determine_correct_effective_period(col_name, row_data, full_effective_date, full_expiration_date)

          same_for_all_fees.merge(
            key => value,
            effective_date: effective_date,
            expiration_date: expiration_date,
            mot: 'ocean',
            rate_basis: 'PER_CONTAINER',
            row_nr: row_nr
          )
        end

        multiple_objs.compact
      end

      def determine_correct_effective_period(col_name, row_data, effective_date, expiration_date)
        if col_name.match?(/(curr_fee|next_fee)/)
          corresponding_month_key = col_name.sub('fee', 'month').remove(%r{/\d+}).to_sym
          effective_month = months_german_to_english(row_data[corresponding_month_key])

          if effective_month && !effective_month.match?(%r{-|incl|n/a})
            month_start = Date.parse("#{effective_month} #{effective_date.year}")
            month_start = Date.parse("#{effective_month} #{expiration_date.year}") if month_start < effective_date

            month_end = month_start.end_of_month.change(usec: 0)
            if month_end < expiration_date
              effective_date = month_start
              expiration_date = month_end
            end
          end
        end

        [effective_date, expiration_date]
      end

      def months_german_to_english(month)
        return if month.nil?

        month = I18n.transliterate(month[0..2]).upcase
        MONTHS_GERMAN_TO_ENGLISH_LOOKUP[month] || month
      end

      def expand_based_on_type_of_fee(multiple_objs)
        same_for_all_keys = [*ROW_IDENTIFIER_KEYS, *ADDITIONAL_KEYS_SAME_FOR_ALL]
        multiple_objs.map do |row_data|
          same_for_all_fees = row_data.slice(*same_for_all_keys)
          fee_column_key, fee_column_value = row_data.except(*same_for_all_keys).first
          fee_is_included = fee_is_included?(fee_column_value)

          preliminary_load_type = determine_preliminary_load_type(fee_column_key)
          fee_type, fee_code, fee_name =
            determine_fee_identifiers(fee_column_key, preliminary_load_type, fee_is_included)

          currency, fee = determine_currency_and_fee(fee_is_included, fee_column_value)
          same_for_all_fees.merge(
            klass_identifier: fee_type,
            preliminary_load_type: preliminary_load_type,
            fee_code: fee_code,
            fee_name: fee_name,
            currency: currency,
            fee: fee,
            fee_min: fee
          )
        end
      end

      def determine_preliminary_load_type(key)
        pure_size_class = key.to_s.scan(/(20_?(dc)?|40_?(dc|hq)?)/).dig(0, 0)
        pure_size_class = pure_size_class&.sub(/_*(dc|hq)/, '_\1')
        "fcl_#{pure_size_class.remove('_dc')}" if pure_size_class
      end

      def determine_fee_identifiers(fee_column_key, preliminary_load_type, fee_is_included)
        col_name = fee_column_key.to_s
        fee_type = OCEAN_FREIGHT_COLUMNS.include?(col_name) ? 'Pricing' : 'LocalCharges'
        fee_code = fee_code_by_fee_type(fee_type, preliminary_load_type, col_name)
        fee_name = fee_code.titleize

        if fee_is_included
          fee_code = "INCLUDED_#{fee_code}"
          fee_name = "#{fee_name} (included)"
        end

        [fee_type, fee_code, fee_name]
      end

      def fee_code_by_fee_type(fee_type, preliminary_load_type, col_name)
        case fee_type
        when 'Pricing'
          preliminary_load_type ? STANDARD_OCEAN_FREIGHT_FEE_CODE : col_name.upcase
        when 'LocalCharges'
          col_name.match(%r{(\D*/)*(\d{2,}(dc|hq)*/)*(.+)})[4].upcase
        end
      end

      def determine_currency_and_fee(fee_is_included, fee_column_value)
        return ['EUR', 0] if fee_is_included
        return [nil, fee_column_value] unless fee_column_value.respond_to?(:currency)

        [fee_column_value.currency.to_s, fee_column_value.to_d]
      end

      def fee_is_included?(value)
        value.match?(/incl/i) if value.respond_to?(:match?)
      end

      def adapt_origin_destination(multiple_objs)
        multiple_objs.each do |row_data|
          row_data[:origin] = row_data.delete(:origin_hub)
          row_data[:country_origin] = row_data.delete(:origin_country)
          row_data[:destination] = row_data.delete(:destination_hub)
          row_data[:country_destination] = row_data.delete(:destination_country)
        end
      end

      def expand_based_on_preliminary_load_type(multiple_objs)
        multiple_objs.flat_map do |row_data|
          preliminary_load_type = row_data.delete(:preliminary_load_type)

          actual_load_types = determine_actual_load_types(preliminary_load_type, row_data[:klass_identifier])
          actual_load_types.map do |load_type|
            row_data.merge(load_type: load_type)
          end
        end
      end

      def determine_actual_load_types(preliminary_load_type, fee_type)
        # `Container::CARGO_CLASSES` is explicitly not used, as SACO operates with a subset of containers types
        # If no container type was explicitly specified in the header, all container classes are returned
        return CONTAINER_CLASSES_LOOKUP.values.flatten unless preliminary_load_type

        if fee_type == 'LocalCharges' && preliminary_load_type.match?(/40$/)
          CONTAINER_CLASSES_LOOKUP[preliminary_load_type]
        else
          [preliminary_load_type]
        end
      end

      def extract_notes(row_data, note_keys)
        row_data.slice(*note_keys).each_with_object([]) do |(key, val), notes|
          next if val.blank?

          header = key.to_s.remove(%r{^note/}).titleize

          notes << {
            header: header,
            body: val.casecmp?('x') ? nil : val,
            remarks: header == 'Remarks',
            transshipment: header == 'Transshipment Via'
          }
        end
      end

      def add_notes_to_pricings(multiple_objs, notes)
        multiple_objs.select { |row_data| row_data[:klass_identifier] == 'Pricing' }.each do |row_data|
          row_data[:notes] = notes
        end
      end

      def pricings_format_to_local_charges_format(rows_data)
        adapt_for_local_charges_format(rows_data)

        grouped_data = rows_data.group_by { |row_data| row_data.slice(*LOCAL_CHARGES_GROUPING_KEYS) }.values
        grouped_data.map do |group|
          same_for_all_in_group = group.first.slice(
            *LOCAL_CHARGES_GROUPING_KEYS,
            :service_level
          )
          row_nrs = group.map { |row_data| row_data[:row_nr] }.join(', ')

          same_for_all_in_group.merge(fees: local_charge_fees_from_group(group), row_nr: row_nrs)
        end
      end

      def adapt_for_local_charges_format(rows_data)
        rows_data.each do |row_data|
          row_data[:service_level] = 'standard'
          row_data[:load_type] = row_data[:load_type]
          row_data[:hub] = row_data.delete(:origin)
          row_data[:hub_locode] = row_data.delete(:origin_locode)
          row_data[:country] = row_data.delete(:country_origin)
          row_data[:counterpart_hub] = row_data.delete(:destination)
          row_data[:counterpart_hub_locode] = row_data.delete(:destination_locode)
          row_data[:counterpart_country] = row_data.delete(:country_destination)
        end
      end

      def local_charge_fees_from_group(group)
        group.each_with_object({}) do |row_data, fees_hsh|
          fee_code = row_data[:fee_code]
          rate_basis = RateBasis.get_internal_key(row_data[:rate_basis].upcase)

          fees_hsh[fee_code] = {
            currency: row_data[:currency],
            key: fee_code,
            min: row_data[:fee_min],
            max: nil,
            name: row_data[:fee_name],
            rate_basis: rate_basis,
            **specific_charge_params(rate_basis, row_data)
          }
        end
      end

      def specific_charge_params(rate_basis, single_data)
        # This is just a slimmed-down version of the similar method in the pure local_charges restructurer
        case rate_basis
        when 'PER_CONTAINER'
          { value: single_data[:fee] }
        end
      end

      def adapt_for_direction(rows_data)
        rows_data.each do |row_data|
          next row_data[:direction] = 'export' unless row_data[:fee_code].downcase.match?(%r{^(included_)?dest/})

          row_data[:direction] = 'import'
          remove_dest_keyword(row_data)
          swap_origin_destination(row_data)
        end
      end

      def remove_dest_keyword(row_data)
        row_data[:fee_code] = row_data[:fee_code].remove(%r{dest/}i)
        row_data[:fee_name] = row_data[:fee_code].titleize
      end

      def swap_origin_destination(row_data)
        temp = row_data[:origin]
        row_data[:origin] = row_data[:destination]
        row_data[:destination] = temp

        temp = row_data[:country_origin]
        row_data[:country_origin] = row_data[:country_destination]
        row_data[:country_destination] = temp

        temp = row_data[:origin_locode]
        row_data[:origin_locode] = row_data[:destination_locode]
        row_data[:destination_locode] = temp
      end
    end
  end
end
