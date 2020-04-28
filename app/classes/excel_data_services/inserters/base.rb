# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Base < ExcelDataServices::Base
      def self.get(klass_identifier)
        "#{parent}::#{klass_identifier.titleize.delete(' ')}".constantize
      end

      def self.insert(options)
        new(options).perform
      end

      def initialize(tenant:, data:, options:)
        @tenant = tenant
        @tenants_tenant = Tenants::Tenant.find_by(legacy_id: tenant.id)
        @scope = ::Tenants::ScopeService.new(
          tenant: tenants_tenant,
          target: ::Tenants::User.find_by(legacy_id: options[:user]&.id)
        ).fetch
        @data = data
        @klass_identifier = self.class.name.split('::').last
        @options = options
        @sandbox = options[:sandbox]
        @group_id = options[:group_id]
        @stats = { errors: [] }
      end

      def perform
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      private

      attr_reader :tenant, :data, :klass_identifier, :options, :stats, :scope, :tenants_tenant

      def metadata(row:)
        document = options[:document]
        {
          row_number: row[:row_nr],
          sheet_name: row[:sheet_name],
          file_name: document&.file&.filename&.to_s,
          document_id: document&.id
        }
      end

      def find_group_id(row)
        return @group_id if @group_id.present?

        return row.group_id if row.group_id.present?

        Tenants::Group.find_by(tenant: tenants_tenant, name: row.group_name).id if row.group_name
      end

      def carrier_from_code(name:)
        Legacy::Carrier.find_or_initialize_by(code: name.downcase).tap do |carrier|
          carrier.name ||= name
          carrier.save
        end
      end

      def add_stats(data_record, row_nr, force_new_record = false)
        descriptor = data_record.class.name.underscore.pluralize.to_sym
        @stats[descriptor] ||= {
          number_created: 0,
          number_updated: 0,
          number_deleted: 0
        }

        if data_record.destroyed?
          @stats[descriptor][:number_deleted] += 1
        elsif !data_record.valid?
          add_error_to_stats(data_record: data_record, row_nr: row_nr)
        elsif data_record.new_record? || force_new_record
          @stats[descriptor][:number_created] += 1
        elsif data_record.changed?
          @stats[descriptor][:number_updated] += 1
        end
      end

      def add_error_to_stats(data_record:, row_nr:)
        @stats[:errors] << {
          reason: data_record.errors.full_messages.join(', '),
          row_nr: row_nr,
          sheet_name: @data.dig(0, 0, :sheet_name)
        }

        @stats[:has_errors] = true if @stats[:has_errors].blank?
      end
    end
  end
end
