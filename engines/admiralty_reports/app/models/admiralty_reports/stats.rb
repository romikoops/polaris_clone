# frozen_string_literal: true

require 'core_ext/array_refinements'

module AdmiraltyReports
  class Stats
    using ArrayRefinements
    include ActionView::Helpers::DateHelper
    attr_reader :year, :month, :tenant

    def initialize(tenant:, year:, month:)
      @tenant = tenant
      @month = month.to_i
      @year = year.to_i
    end

    def overview
      shipment_type = quotation_tool? ? uniq_quotations_by_original_shipments : uniq_shipments_by_original_shipments
      shipments = shipments_for(shipment_type)
      ship_bundle = shipment_type.zip(shipments)
      ship_bundle_groups = group_by_date(ship_bundle)

      @overview ||= ship_bundle_groups.each_with_object({}) do |(k_date, v_bundle), result_hsh|
        agent_counts = shipments_per_agent(v_bundle)

        result_hsh[k_date] = { data_per_agent: transform_agent_counts(agent_counts),
                               combined_data: summarize_data(agent_counts, v_bundle) }
      end
    end

    def find_years
      @find_years ||= original_shipments.pluck(:created_at).map(&:year).uniq
    end

    def metrics
      return {} if month.zero?

      @metrics ||= MetricsCalculator.calculate(overview: overview,
                                               start_date: start_date,
                                               end_date: end_date,
                                               quotation_tool: @quotation_tool)
    end

    def quotation_tool?
      @quotation_tool ||= tenant.scope.content.values_at('closed_quotation_tool', 'open_quotation_tool').any?
    end

    private

    def original_shipments
      ::Legacy::Shipment.where(tenant_id: tenant.legacy_id)
                        .joins(:user)
                        .where(users: { internal: false })
                        .where.not(users: { email: excluded_emails })
                        .distinct
    end

    def uniq_quotations_by_original_shipments
      quotation = ::Legacy::Quotation.where(original_shipment_id: original_shipments.ids)
      quotation = filtered(quotation)
      quotation.order(updated_at: :desc).uniq(&:original_shipment_id)
    end

    def uniq_shipments_by_original_shipments
      shipments = original_shipments.where.not(status: 'booking_process_started')
      shipments = filtered(shipments)
      shipments.order(updated_at: :desc).uniq(&:id)
    end

    def filtered(shipments)
      return shipments if start_date.nil?

      filtered = shipments.where(created_at: start_date..end_date)
      filtered.empty? ? shipments : filtered
    end

    def start_date
      @start_date ||= DateTime.new(year, month, 1) unless month.zero?
    end

    def end_date
      if month == Time.now.month && year == Time.now.year
        DateTime.now
      else
        start_date.end_of_month
      end
    end

    def shipments_for(shipment_type)
      ::Legacy::Shipment.where(id: shipment_type.pluck(:original_shipment_id).uniq)
    end

    def excluded_emails
      tenant.scope.content['blacklisted_emails']
    end

    def group_by_date(bundle)
      bundle.group_by do |shipment_type, _shipment|
        shipment_type.updated_at.to_date
      end
    end

    def shipments_per_agent(bundle)
      bundle.tally_by do |shipment_type, _shipment|
        user = ::Legacy::User.with_deleted.find_by(id: shipment_type.user_id)
        agency = ::Legacy::Agency.find_by(id: user.agency_id) if user
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
        n_shipments: bundle.count,
        avg_time_for_booking_process: avg_time_for_booking_process(bundle) }
    end

    def avg_time_for_booking_process(bundle)
      times = if quotation_tool?
                bundle.map { |quotation, shipment| quotation.updated_at - shipment.created_at }
              else
                bundle.map { |booking, _shipment| booking.updated_at - booking.created_at }
              end

      time_ago_in_words(times.sum.fdiv(times.size).seconds.ago)
    end
  end
end
