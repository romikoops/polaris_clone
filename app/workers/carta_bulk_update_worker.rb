# frozen_string_literal: true

class CartaBulkUpdateWorker
  include Sidekiq::Worker
  sidekiq_options retry: 10

  def perform
    Carta::BulkIndexUpdater.perform
  end
end

Sidekiq::Cron::Job.create(
  name: "Carta Bulk Update worker - every morning",
  cron: "0 1 * * *",
  class: "CartaBulkUpdateWorker"
)
