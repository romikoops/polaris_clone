# frozen_string_literal: true

class BackfillStatusAndCurrencyToQueryWorker
  include Sidekiq::Worker

  FaileStatusAndCurrencyBackFill = Class.new(StandardError)

  def perform
    status_currency_backfill_sql
    raise FaileStatusAndCurrencyBackFill if backfill_failed?
  end

  def status_currency_backfill_sql
    ActiveRecord::Base.connection.execute("

      WITH latest_result_sets AS (
        SELECT DISTINCT ON (query_id)
          status, currency, query_id
        FROM journey_result_sets
        ORDER BY query_id, created_at DESC
      )
      UPDATE journey_queries
      SET status = latest_result_sets.status, currency = latest_result_sets.currency
      FROM latest_result_sets
      WHERE latest_result_sets.query_id = journey_queries.id
      AND journey_queries.status IS NULL
    ")
  end

  def backfill_failed?
    queries_without_result_set = Journey::Query.where.not(id: Journey::ResultSet.select(:query_id).map(&:query_id).uniq)
    Journey::Query.where(status: nil).where.not(id: queries_without_result_set).present?
  end
end
