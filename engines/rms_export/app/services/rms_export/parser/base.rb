# frozen_string_literal: true

module RmsExport
  module Parser
    class Base
      def initialize(tenant_id:, sandbox: nil)
        @tenant = Tenants::Tenant.find_by(id: tenant_id)
        @sandbox = sandbox
      end

      def create_csv_file(data:, key:, headers: false)
        return nil if data.empty?

        file = Tempfile.new("#{key}.csv")
        CSV.open(file, 'wb') do |csv|
          csv << data.first.keys if headers

          data.each do |hash|
            csv << hash.values
          end
        end

        file
      end

      def time_factor(mot, service)
        category = determine_category(service)&.to_i
        case mot.downcase
        when 'ocean'
          [nil, 3, 5, 8][category]
        when 'air'
          [nil, 0.5, 1.5, 3][category]
        when 'rail'
          [nil, 6, 7, 9][category]
        when 'truck'
          [nil, 3, 5, 7][category]
        when 'carriage'
          [nil, 3, 5, 7][category]
        end
      end

      def price_factor(mot, service)
        category = determine_category(service)&.to_i
        case mot.downcase
        when 'ocean'
          [nil, 7, 5, 3][category]
        when 'air'
          [nil, 9, 7, 6][category]
        when 'rail'
          [nil, 6, 4, 2][category]
        when 'truck'
          [nil, 6, 5, 4][category]
        when 'carriage'
          [nil, 6, 5, 4][category]
        end
      end

      def allowed_cargo_bitwise(row:, headers:)
        lcl = row[headers.index('LCL')] == 'true' ? 1 : 0
        fcl = row[headers.index('FCL')] == 'true' ? 2 : 0
        reefer = row[headers.index('REEFER')] == 'true' ? 4 : 0
        [lcl, fcl, reefer].sum
      end

      def determine_category(service)
        if %w(fastest express).include?(service)
          '1'
        elsif %w(cheapest slowest).include?(service)
          '3'
        else
          '2'
        end
      end

      def mode_of_transport_enum(mot)
        { ocean: 1, air: 2, rail: 3, truck: 4, carriage: 5 }[mot&.downcase&.to_sym] || 0
      end
    end
  end
end
