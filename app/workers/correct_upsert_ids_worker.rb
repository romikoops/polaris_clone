# frozen_string_literal: true

class CorrectUpsertIdsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    BackfillUpsertIdOnPricingsAndFeesWorker.new.perform
    BackfillUpsertIdOnItineraryWorker.new.perform
  end
end
