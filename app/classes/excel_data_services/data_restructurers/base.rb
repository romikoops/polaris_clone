# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurers
    class Base < ExcelDataServices::Base # rubocop:disable Metrics/ClassLength
      ROWS_BY_PRICING_PARAMS_GROUPING_KEYS = %i(
        effective_date
        expiration_date
        customer_email
        origin
        country_origin
        destination
        country_destination
        mot
        carrier
        service_level
        load_type
        rate_basis
      ).freeze

      ROWS_BY_MARGIN_PARAMS_GROUPING_KEYS = ROWS_BY_PRICING_PARAMS_GROUPING_KEYS.without(:customer_email).freeze

      def self.get(klass_identifier)
        "#{parent}::#{klass_identifier.titleize.delete(' ')}".constantize
      end

      def self.restructure(options)
        klass_identifier = options[:data][:data_restructurer_name]
        child_klass = klass_identifier ? get(klass_identifier) : self
        child_klass.new(options).perform
      end

      def initialize(tenant:, data:)
        @tenant = tenant
        @data = data
      end

      def perform
        { 'Unknown' => data }
      end

      private

      attr_reader :tenant, :data

      def replace_nil_equivalents_with_nil(rows_data)
        rows_data.each do |row_data|
          row_data.each do |k, v|
            row_data[k] = nil if v.to_s.strip.match?(%r{^n/a$|^-$|^$}i) # 'n/a', '-', ''
          end
        end
      end

      def clean_html_format_artifacts(rows_data)
        rows_data.each do |row_data|
          row_data.keys.each do |key|
            new_key = key.to_s.remove('html')
                         .remove(/(?<=[^a-z])[a-z](?=[^a-z])/)
                         .remove(%r{(?<![a-z0-9\(])(_|/)})
                         .remove(%r{(_|/)(?![a-z0-9\(])})
                         .to_sym
            row_data[new_key] = row_data.delete(key)
          end
        end
      end

      def downcase_load_types(rows_data)
        rows_data.each do |row_data|
          row_data[:load_type].downcase!
        end
      end

      def expand_fcl_to_all_sizes(rows_data)
        plain_fcl_local_charges_params = rows_data.select { |row_data| row_data[:load_type] == 'fcl' }

        expanded_local_charges_params = Container::CARGO_CLASSES.reduce([]) do |memo, fcl_size|
          memo + plain_fcl_local_charges_params.map do |params|
            params.dup.tap { |pms| pms[:load_type] = fcl_size }
          end
        end
        rows_data.reject! { |params| params[:load_type] == 'fcl' }
        rows_data + expanded_local_charges_params
      end

      def expand_based_on_date_overlaps(rows_data)
        grouped = group_by_params(rows_data, ROWS_BY_PRICING_PARAMS_GROUPING_KEYS - %i(effective_date expiration_date))
        result = grouped.map do |group|
          sorted_group = group.sort_by { |row_data| row_data.values_at(:effective_date, :expiration_date) }
          sorted_group.map.with_index do |b, i|
            expanded_rest = sorted_group[0...i].map do |a|
              next if no_overlap_or_exact_match?(a, b)

              if b[:expiration_date] <= a[:expiration_date]
                [copy_of_a_as_long_as_b(a, b)]
              else
                copies_of_a_and_b_with_matching_dates(a, b)
              end
            end

            [b] + expanded_rest
          end
        end

        result.flatten.uniq.compact
      end

      def no_overlap_or_exact_match?(row_data_a, row_data_b)
        (row_data_b[:effective_date] > row_data_a[:expiration_date] ||
          row_data_a.values_at(:effective_date, :expiration_date) ==
          row_data_b.values_at(:effective_date, :expiration_date))
      end

      def copy_of_a_as_long_as_b(row_a, row_b)
        row_a.dup.tap do |el|
          el[:effective_date] = row_b[:effective_date]
          el[:expiration_date] = row_b[:expiration_date]
        end
      end

      def copies_of_a_and_b_with_matching_dates(row_a, row_b)
        [row_a.dup.tap { |el| el[:effective_date] = row_b[:effective_date] },
         row_b.dup.tap { |el| el[:expiration_date] = row_a[:expiration_date] }]
      end

      def group_by_params(rows_data, params)
        rows_data.group_by { |row| row.slice(*params) }.values
      end

      def add_hub_names(rows_data)
        rows_data.each do |row_data|
          row_data[:origin_name] = append_hub_suffix(row_data[:origin], row_data[:mot])
          row_data[:destination_name] = append_hub_suffix(row_data[:destination], row_data[:mot])
        end
      end
    end
  end
end
