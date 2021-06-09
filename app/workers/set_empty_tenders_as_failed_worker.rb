# frozen_string_literal: true

class SetEmptyTendersAsFailedWorker
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE journey_result_sets
        SET status = 'failed'
        FROM journey_results
        JOIN quotations_tenders
          ON quotations_tenders.id = journey_results.id
        LEFT OUTER JOIN quotations_line_items
          ON quotations_tenders.id = quotations_line_items.tender_id
        WHERE quotations_line_items.tender_id IS NULL
        AND journey_result_sets.id = journey_results.result_set_id
      SQL
    )
  end
end
