# frozen_string_literal: true

class SetFailedResultSetsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    invalid_queries = Journey::Query.where.not(id: Journey::ResultSet.select(:query_id))
    total invalid_queries.count
    invalid_queries.find_each.with_index do |query, index|
      at(index + 1)
      Journey::ResultSet.create(
        status: "failed",
        query: query,
        created_at: query.created_at,
        currency: query.client&.settings&.currency || query.organization.scope.default_currency
      )
    end
  end
end
