# frozen_string_literal: true

require 'core_ext/array_refinements'

module AdmiraltyReports
  class MetricsCalculator
    def self.calculate(overview:, start_date:, end_date:)
      new(overview: overview, start_date: start_date, end_date: end_date).result
    end

    def initialize(overview:, start_date:, end_date:)
      @overview = overview
      @start_date = start_date
      @end_date = end_date
    end

    def result
      {
        total_shipments: total_shipments,
        total_active_agents_companies: total_active(:agency_name),
        total_active_users: total_active(:email),
        average_shipments_per_agent_company: average_shipments(:agency_name),
        average_shipments_per_user: average_shipments(:email),
        shipments_per_day_without_weekends: (total_shipments / weekdays),
        most_active_agent_company: data_per_month[:agencies].first,
        most_active_user: data_per_month[:users].first,
        weekdays_without_activity: weekdays_without_activity,
        most_active_day: activity_per_day.last,
        least_active_day: activity_per_day.first
      }
    end

    private

    attr_reader :end_date, :start_date, :overview

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
      agencies_data = {}

      overview.each do |stat|
        stat.second[:data_per_agent].each do |agent_data|
          email = agent_data[:email]
          count = agent_data[:count]

          if users_data[email].nil?
            users_data[email] = count
          else
            users_data[email] += count
          end

          agency_name = agent_data[:agency_name]
          if agencies_data[agency_name].nil?
            agencies_data[agency_name] = count
          else
            agencies_data[agency_name] += count
          end
        end
      end

      { users: sort_by_count(users_data),
        agencies: sort_by_count(agencies_data) }
    end

    def sort_by_count(data)
      data.sort_by { |_, v| -v }.to_h
    end

    def weekdays
      (start_date..end_date).count(&:on_weekday?)
    end

    def weekdays_without_activity
      return if start_date.nil?

      (start_date..end_date).count do |day|
        !overview.has_key?(day.to_date) && day.to_date.on_weekday?
      end
    end

    def activity_per_day
      overview.sort_by { |stat| stat.second[:combined_data][:n_shipments] }.map(&:first)
    end
  end
end
