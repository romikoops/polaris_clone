# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Base < ExcelDataServices::Base
      def self.get(klass_identifier)
        "#{parent}::#{klass_identifier.titleize.delete(" ")}".constantize
      end

      def self.insert(options)
        new(options).perform
      end

      def initialize(organization:, data:, options:)
        @organization = organization
        @scope = ::OrganizationManager::ScopeService.new(
          organization: organization,
          target: ::Users::Client.find_by(id: options[:user]&.id)
        ).fetch
        @data = data
        @klass_identifier = self.class.name.split("::").last
        @options = options
        @group_id = options[:group_id]
        @stats = {errors: []}
      end

      def perform
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      private

      attr_reader :data, :klass_identifier, :options, :stats, :scope, :group_id

      def metadata(row:)
        document = options[:document]
        {
          row_number: row[:row_nr],
          sheet_name: row[:sheet_name],
          file_name: document&.file&.filename&.to_s,
          document_id: document&.id
        }
      end

      def find_group_id(row:)
        if group_id.present?
          group_id
        elsif row.group_id.present?
          row.group_id
        else
          group = Groups::Group.find_by(organization: organization, name: row.group_name)
          group ||= default_group
          group.id
        end
      end

      def carrier_from_code(name:)
        Legacy::Carrier.find_or_initialize_by(code: name.downcase).tap do |carrier|
          carrier.name ||= name
          carrier.save
        end
      end

      def find_or_create_transit_time(row:, itinerary:, tenant_vehicle:)
        return if row.transit_time.blank?

        Legacy::TransitTime.find_or_initialize_by(
          itinerary: itinerary,
          tenant_vehicle: tenant_vehicle
        ).tap do |transit_time|
          transit_time.duration = row.transit_time
          transit_time.save
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
          reason: data_record.errors.full_messages.join(", "),
          row_nr: row_nr,
          sheet_name: @data.dig(0, 0, :sheet_name)
        }

        @stats[:has_errors] = true if @stats[:has_errors].blank?
      end

      def default_group
        @default_group ||= Groups::Group.find_by(name: "default", organization: organization)
      end
    end
  end
end
