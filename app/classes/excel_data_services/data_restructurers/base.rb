# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurers
    class Base
      FCL_SIZE_CLASSES = %w(
        fcl_20
        fcl_40
        fcl_40_hq
      ).freeze

      MOT_HUB_NAME_LOOKUP =
        { 'ocean' => 'Port',
          'air' => 'Airport',
          'rail' => 'Railyard',
          'truck' => 'Depot' }.freeze

      LOCODE_TO_NAME_LOOKUP =
        { 'DEHAM' => 'Hamburg',
          'BEANR' => 'Antwerp',
          'DEBRV' => 'Bremerhaven',
          'NLRTM' => 'Rotterdam' }.freeze

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
        rows_data.map do |row_data|
          row_data.each do |k, v|
            row_data[k] = nil if v.to_s =~ %r{^n/a$|^-$|^$}i # 'n/a', '-', ''
          end

          row_data
        end
      end

      def downcase_load_types(rows_data)
        rows_data.each do |row_data|
          row_data[:load_type].downcase!
        end
      end

      def expand_fcl_to_all_sizes(rows_data)
        plain_fcl_local_charges_params = rows_data.select { |row_data| row_data[:load_type] == 'fcl' }
        expanded_local_charges_params = FCL_SIZE_CLASSES.reduce([]) do |memo, fcl_size|
          memo + plain_fcl_local_charges_params.map do |params|
            params.dup.tap do |pms|
              pms[:load_type] = fcl_size
            end
          end
        end
        rows_data = rows_data.reject { |params| params[:load_type] == 'fcl' }
        rows_data + expanded_local_charges_params
      end

      def determine_location_name_from_locode(locode)
        # Just a hardcoded lookup for now, will be done properly in Phoenix
        LOCODE_TO_NAME_LOOKUP[locode.delete(' ')]
      end

      def group_by_pricing_params(rows_data)
        rows_data.group_by { |row| row.slice(*ROWS_BY_PRICING_PARAMS_GROUPING_KEYS) }.values
      end

      def append_hub_suffix(name, mot)
        name + ' ' + MOT_HUB_NAME_LOOKUP[mot]
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
