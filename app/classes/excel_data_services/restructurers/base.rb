# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class Base < ExcelDataServices::Base
      ROWS_BY_PRICING_PARAMS_GROUPING_KEYS = %i[
        carrier
        country_destination
        country_origin
        customer_email
        destination
        destination_locode
        effective_date
        expiration_date
        internal
        load_type
        mot
        origin
        origin_locode
        rate_basis
        service_level
      ].freeze

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

      def cut_based_on_date_overlaps(rows_data, grouping_keys)
        grouped = group_by_params(rows_data, grouping_keys)
        result = grouped.flat_map do |group|
          cut_off_dates = group.flat_map { |row| row.values_at(:effective_date, :expiration_date) }.uniq.sort
          group.flat_map { |row| cut_into_pieces(row, cut_off_dates) }
        end

        result.uniq
      end

      def cut_into_pieces(row, cut_off_dates)
        applicable_dates = cut_off_dates.select { |date| date.between?(row[:effective_date], row[:expiration_date]) }

        applicable_dates.each_cons(2).each_with_object([]) do |(effective_date, expiration_date), pieces|
          effective_date += 1.day if effective_date == effective_date.end_of_month
          expiration_date -= 1.day if expiration_date == expiration_date.beginning_of_month

          next if (expiration_date - effective_date).to_i <= 1 # skip if dates are back to back

          pieces << row.dup.tap do |el|
            el[:effective_date] = effective_date
            el[:expiration_date] = expiration_date
          end
        end
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
