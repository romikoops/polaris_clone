# frozen_string_literal: true

class BackfillOfferLineItemSetsWorker
  include Sidekiq::Worker

  def perform(*args)
    Journey::Offer.find_each do |offer|
      Journey::Result.where(id: Journey::OfferResult.where(offer: offer).select(:result_id)).each do |result|
        Journey::OfferLineItemSet.create(
          offer: offer,
          line_item_set: result.line_item_sets.order(created_at: :asc).first
        )
      end
    end
  end
end
