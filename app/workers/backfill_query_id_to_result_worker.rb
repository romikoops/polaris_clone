# frozen_string_literal: true

class BackfillQueryIdToResultWorker
  include Sidekiq::Worker

  FailedQueryIdBackFill = Class.new(StandardError)
  def perform
    journey_result_backfill_sql
    raise FailedQueryIdBackFill unless verify_backfill_mismatch
  end

  def journey_result_backfill_sql
    ActiveRecord::Base.connection.execute("
      UPDATE journey_results
      SET query_id = journey_result_sets.query_id
      FROM journey_result_sets
      WHERE journey_result_sets.id = journey_results.result_set_id
    ")
  end

  def verify_backfill_mismatch
    Journey::Result.joins(:result_set).where("journey_results.query_id != journey_result_sets.query_id").count.zero?
  end
end
