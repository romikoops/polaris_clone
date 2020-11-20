# frozen_string_literal: true

require "core_ext/array_refinements"

module AdmiraltyReports
  class Stats
    using ArrayRefinements
    include ActionView::Helpers::DateHelper
    attr_reader :year, :month, :organization
    NON_LEGACY_QUOTATIONS_DATE = DateTime.new(2019, 11, 25, 14, 31, 47, "+0100")

    def initialize(organization:, year:, month:)
      @organization = organization
      @month = month.to_i
      @year = year.to_i
      @scope = ::OrganizationManager::ScopeService.new(organization: @organization).fetch
    end

    def overview
      grouped_requests = quotation_tool? ? uniq_quotations_by_original_shipments : uniq_shipments_by_original_shipments
      ship_bundle_groups = group_by_date(grouped_requests)

      @overview ||= ship_bundle_groups.each_with_object({}) { |(k_date, v_bundle), result_hsh|
        agent_counts = shipments_per_agent(v_bundle)

        result_hsh[k_date] = {data_per_agent: transform_agent_counts(agent_counts),
                              combined_data: summarize_data(agent_counts, v_bundle)}
      }
    end

    def raw_request_data
      quotation_tool? ? uniq_quotations_by_original_shipments : uniq_shipments_by_original_shipments
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
      @quotation_tool ||= @scope.values_at("closed_quotation_tool", "open_quotation_tool").any?
    end

    private

    def excluded_users
      Users::User.with_deleted
        .select(:id)
        .where(email: excluded_emails)
    end

    def original_shipments
      ::Legacy::Shipment.where(organization_id: organization.id)
        .includes(:user)
        .where.not(user_id: excluded_users.ids, billing: :test)
        .distinct
    end

    def non_flagged_quotations
      ::Quotations::Quotation.where(organization: @organization)
        .includes(:user)
        .where.not(user_id: excluded_users.ids, billing: :test)
        .distinct
    end

    def uniq_quotations_by_original_shipments
      legacy_quotations = filtered(::Legacy::Quotation.where(original_shipment_id: original_shipments.ids)
                                                      .where("created_at < ?", NON_LEGACY_QUOTATIONS_DATE)
                                                      .where.not(billing: :test))
      non_legacy_quotations = filtered(non_flagged_quotations)
      quotations = legacy_quotations | non_legacy_quotations
      quotations.sort_by(&:created_at).reverse.uniq
    end

    def uniq_shipments_by_original_shipments
      shipments = original_shipments.where.not(status: "booking_process_started")
      shipments = filtered(shipments)
      shipments.order(created_at: :desc).uniq(&:id)
    end

    def filtered(shipments)
      return shipments if start_date.nil?

      shipments.where(created_at: start_date..end_date)
    end

    def start_date
      @start_date ||= DateTime.new(year, month, 1) unless month.zero?
    end

    def end_date
      if month == Time.zone.now.month && year == Time.zone.now.year
        DateTime.now
      else
        start_date.end_of_month
      end
    end

    def excluded_emails
      @scope["blacklisted_emails"]
    end

    def group_by_date(bundle)
      bundle.group_by do |shipment_type, _shipment|
        shipment_type.created_at.to_date
      end
    end

    def shipments_per_agent(bundle)
      bundle.tally_by do |shipment_type, _shipment|
        user = ::Users::User.with_deleted.find_by(id: shipment_type.user_id)
        company = Companies::Membership.find_by(member: user)&.company if user
        [user&.email, company&.name]
      end
    end

    def transform_agent_counts(agent_counts)
      agent_counts.each_with_object([]) do |((email, company_name), count), arr|
        arr << {email: email, company_name: company_name, count: count}
      end
    end

    def summarize_data(agent_counts, bundle)
      {n_individual_agents: agent_counts.keys.count,
       n_shipments: bundle.count,
       avg_time_for_booking_process: avg_time_for_booking_process(bundle)}
    end

    def avg_time_for_booking_process(bundle)
      times = if quotation_tool?
        bundle.map do |quotation, shipment|
          quotation.updated_at - (shipment ? shipment.created_at : quotation.created_at)
        end
      else
        bundle.map { |booking, _shipment| booking.updated_at - booking.created_at }
      end

      time_ago_in_words(times.sum.fdiv(times.size).seconds.ago)
    end
  end
end
