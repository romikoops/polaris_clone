# frozen_string_literal: true

module Wheelhouse
  class OfferBuilder
    attr_reader :results

    def self.offer(results:)
      new(results: results).offer
    end

    def initialize(results:)
      @results = results
    end

    def offer
      returnable_offer.tap do |old_or_new_offer|
        generate_pdf(offer: old_or_new_offer) if generate_pdf? 
        publish_event(created_offer: old_or_new_offer) if publish_event?
      end
    end

    private

    def old_offer
      @old_offer ||= begin
        query = """
          SELECT *
          FROM journey_offers
          WHERE id = (
            SELECT offer_id
            FROM journey_offer_line_item_sets
            JOIN journey_offers on journey_offer_line_item_sets.offer_id = journey_offers.id
            WHERE line_item_set_id IN (:line_item_set_ids)
            AND journey_offers.query_id = :query_id
            GROUP BY journey_offer_line_item_sets.id
            HAVING COUNT(DISTINCT line_item_set_id) = :result_count
            LIMIT 1
          )
        """
        binds = {
          line_item_set_ids: line_item_sets.map(&:id),
          result_count: results.count,
          query_id: results.first.query.id
        }

        Journey::Offer.find_by_sql([query, binds]).first
      end
    end

    def new_offer
      Journey::Offer.create(query: results.first.query, line_item_sets: line_item_sets)
    end

    def returnable_offer
      @returnable_offer ||= (old_offer || new_offer)
    end

    def publish_event?
      old_offer.nil?
    end

    def line_item_sets
      @line_item_sets ||= results.map { |result| result.line_item_sets.order(created_at: :desc).first }
    end

    def generate_pdf?
      !returnable_offer.file.attached?
    end

    def generate_pdf(offer:)
      Pdf::Quotation::Client.new(offer: offer).file
    end

    def publish_event(created_offer:)
      Rails.configuration.event_store.publish(
        Journey::OfferCreated.new(data: {
          offer: created_offer.to_global_id, organization_id: Organizations.current_id
        }),
        stream_name: "Organization$#{Organizations.current_id}"
      )
    end
  end
end
