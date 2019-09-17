# frozen_string_literal: true

require 'core_ext/array_refinements'

module AdmiraltyReports
  module StatsCreator
    class Quotations
      using ArrayRefinements
      include ActionView::Helpers::DateHelper

      def initialize(tenant)
        @tenant = tenant
      end

      def perform
        quotations = uniq_quotations_by_original_shipments
        shipments = shipments_for_quotations(quotations)
        quot_ship_bundle = quotations.zip(shipments)
        quot_ship_bundle_groups = group_by_date(quot_ship_bundle)

        quot_ship_bundle_groups.each_with_object({}) do |(k_date, v_bundle), result_hsh|
          agent_counts = quotations_per_agent(v_bundle)

          result_hsh[k_date] = { data_per_agent: transform_agent_counts(agent_counts),
                                 combined_data: summarize_data(agent_counts, v_bundle) }
        end
      end

      private

      attr_reader :tenant

      def uniq_quotations_by_original_shipments
        Quotation.where(original_shipment_id: original_shipments.ids)
                 .order(updated_at: :asc)
                 .uniq(&:original_shipment_id)
      end

      def original_shipments
        Shipment.where(tenant_id: tenant.id)
                .joins(:user)
                .where(users: { internal: false })
                .where.not(users: { email: excluded_emails })
                .distinct
      end

      def shipments_for_quotations(quotations)
        Shipment.where(id: quotations.pluck(:original_shipment_id).uniq)
      end

      def excluded_emails
        Tenant.find_by(legacy_id: tenant.id).scope.content['blacklisted_emails']
      end

      def group_by_date(bundle)
        bundle.group_by do |quotation, _shipment|
          quotation.updated_at.strftime('%m/%d/%Y')
        end
      end

      def quotations_per_agent(bundle)
        bundle.tally_by do |quotation, _shipment|
          user = User.find(quotation.user_id)
          agency = Agency.find_by(id: user.agency_id)
          [user&.email, agency&.name]
        end
      end

      def transform_agent_counts(agent_counts)
        agent_counts.each_with_object([]) do |((email, agency_name), count), arr|
          arr << { email: email, agency_name: agency_name, count: count }
        end
      end

      def summarize_data(agent_counts, bundle)
        { n_individual_agents: agent_counts.keys.count,
          n_quotations: bundle.count,
          avg_time_for_booking_process: avg_time_for_booking_process(bundle) }
      end

      def avg_time_for_booking_process(bundle)
        times = bundle.map { |quotation, shipment| quotation.updated_at - shipment.created_at }
        time_ago_in_words(times.sum.fdiv(times.size).seconds.ago)
      end
    end
  end
end
