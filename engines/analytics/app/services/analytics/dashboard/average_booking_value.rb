# frozen_string_literal: true

module Analytics
  module Dashboard
    class AverageBookingValue < Analytics::Dashboard::Base
      def data
        @data ||= average_result_value
      end

      private

      def average_result_value
        result_count = results.length
        return { symbol: currency, value: 0 } if result_count.zero?

        money = results_with_totals.inject(Money.new(0, currency)) do |sum, record|
          sum + Money.new(record["sum"], record["currency"])
        end

        {
          symbol: money.currency.iso_code,
          value: money.amount / result_count
        }
      end

      def currency
        scope[:default_currency]
      end

      def results_with_totals
        sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, binds])
        ActiveRecord::Base.connection.exec_query(sanitized_query).to_a
      end

      def binds
        { organization_id: organization.id, start_date: start_date, end_date: end_date }
      end

      def query
        <<-SQL
        SELECT
          journey_results.id, journey_queries.currency, SUM(journey_line_items.total_cents * journey_line_items.exchange_rate)
          FROM journey_results
          JOIN journey_queries ON journey_queries.id = journey_results.query_id
          JOIN journey_line_item_sets ON journey_line_item_sets.result_id = journey_results.id
          JOIN journey_line_items ON journey_line_item_sets.id = journey_line_items.line_item_set_id
          WHERE journey_queries.organization_id = :organization_id
          AND journey_queries.status = 'completed'
          AND journey_queries.created_at > :start_date
          AND journey_queries.created_at < :end_date
          GROUP BY journey_results.id, journey_queries.currency
        SQL
      end
    end
  end
end
