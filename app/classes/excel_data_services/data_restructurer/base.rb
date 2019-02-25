# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurer
    class Base
      MOT_HUB_NAME_LOOKUP = { 'ocean' => 'Port',
                              'air' => 'Airport',
                              'rail' => 'Railyard',
                              'truck' => 'Depot' }.freeze

      def self.restructure_data(options)
        new(options).perform
      end

      def initialize(tenant:, data:, klass_identifier:)
        @tenant = tenant
        @data = data
        @klass_identifier = klass_identifier
      end

      def perform
        data
      end

      private

      attr_reader :data, :tenant

      def expand_fcl_to_all_sizes(rows_data)
        plain_fcl_local_charges_params = rows_data.select { |params| params[:load_type] == 'fcl' }
        expanded_local_charges_params = %w(fcl_20 fcl_40 fcl_40_hq).reduce([]) do |memo, fcl_size|
          memo + plain_fcl_local_charges_params.map do |params|
            params.dup.tap do |param|
              param[:load_type] = fcl_size
            end
          end
        end
        rows_data = rows_data.reject { |params| params[:load_type] == 'fcl' }
        rows_data + expanded_local_charges_params
      end

      def append_hub_suffix(name, mot)
        name + ' ' + MOT_HUB_NAME_LOOKUP[mot]
      end
    end
  end
end
