# frozen_string_literal: true

require 'core_ext/array_refinements'

module AdmiraltyReports
  class MetricsCalculator
    def self.calculate(overview:, start_date:, end_date:, quotation_tool:)
      new(overview: overview, start_date: start_date, end_date: end_date, quotation_tool: quotation_tool).result
    end

    def initialize(overview:, start_date:, end_date:, quotation_tool:)
      @overview = overview
      @start_date = start_date
      @end_date = end_date
      @quotation_tool = quotation_tool
    end

    def result
      alter_result_keys(
        total_shipments: total_shipments,
        total_active_companies: total_active(:company_name),
        total_active_users: total_active(:email),
        average_shipments_per_agent_company: average_shipments(:company_name),
        average_shipments_per_user: average_shipments(:email),
        shipments_per_day_without_weekends: (total_shipments / weekdays.length),
        most_active_agent_company: data_per_month[:companies].first,
        most_active_user: data_per_month[:users].first,
        weekdays_without_activity: weekdays_without_activity.length,
        three_most_active_days: days_sorted_by_activity(order: :asc, days: 3),
        three_least_active_days: days_sorted_by_activity(order: :desc, days: 3)
        )
    end

    private

    attr_reader :end_date, :start_date, :overview, :quotation_tool

    def total_shipments
      @total_shipments ||= overview.inject(0) { |sum, stat| sum + stat.second[:combined_data][:n_shipments] }
    end

    def total_active(field)
      overview.map { |stat| stat.second[:data_per_agent].pluck(field) }.flatten.uniq.count
    end

    def average_shipments(field)
      total_active = total_active(field).to_f
      return 0 if total_active.zero?

      (total_shipments / total_active).round(2)
    end

    def data_per_month
      users_data = {}
      companies_data = {}

      overview.each do |stat|
        stat.second[:data_per_agent].each do |agent_data|
          email = agent_data[:email]
          count = agent_data[:count]

          if users_data[email].nil?
            users_data[email] = count
          else
            users_data[email] += count
          end

          company_name = agent_data[:company_name]
          if companies_data[company_name].nil?
            companies_data[company_name] = count
          else
            companies_data[company_name] += count
          end
        end
      end

      { users: sort_by_count(users_data),
        companies: sort_by_count(companies_data) }
    end

    def sort_by_count(data)
      data.sort_by { |_, v| -v }.to_h
    end

    def weekdays
      @weekdays ||= (start_date..end_date).reject(&:on_weekend?)
    end

    def weekdays_without_activity
      @weekdays_without_activity ||= weekdays.reject { |weekday| overview.has_key?(weekday.to_date) }
    end

    def days_sorted_by_activity(order:, days:)
      result = {}
      overview.each do |stat|
        result[stat.first] = stat.second[:combined_data][:n_shipments]
      end

      weekdays_without_activity.each do |weekday_without_activity|
        result[weekday_without_activity.to_date] = 0
      end

      result = result.sort_by { |_k, v| v }
      result = order == :asc ? result.last(days) : result.first(days)
      result.to_h
    end

    def alter_result_keys(result)
      return result unless @quotation_tool

      quotation_result = {}
      result.each do |k, v|
        quotation_result[k] = v unless k.to_s.include?('shipment')
        quotation_key = k.to_s.gsub('shipment', 'quotation').to_sym
        quotation_result[quotation_key] = v
      end
      quotation_result
    end
  end
end
