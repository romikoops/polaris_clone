# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserters
    class Base
      def self.get(klass_identifier)
        "#{parent}::#{klass_identifier.titleize.delete(' ')}".constantize
      end

      def self.insert(options)
        new(options).perform
      end

      def initialize(tenant:, data:, options:)
        @tenant = tenant
        @tenants_tenant = Tenants::Tenant.find_by(legacy_id: tenant&.id)
        @scope = ::Tenants::ScopeService.new(tenant: tenants_tenant, target: options[:user]).fetch
        @data = data
        @klass_identifier = self.class.name.split('::').last
        @options = options
        @sandbox = options[:sandbox]
        @stats = {}
      end

      def perform
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      private

      attr_reader :tenant, :data, :klass_identifier, :options, :stats, :scope, :tenants_tenant

      def add_stats(data_record, force_new_record = false)
        descriptor = data_record.class.name.underscore.pluralize.to_sym
        @stats[descriptor] ||= {
          number_created: 0,
          number_updated: 0,
          number_deleted: 0
        }

        if data_record.new_record? || force_new_record
          @stats[descriptor][:number_created] += 1
        elsif data_record.changed?
          @stats[descriptor][:number_updated] += 1
        elsif data_record.destroyed?
          @stats[descriptor][:number_deleted] += 1
        end
      end
    end
  end
end
