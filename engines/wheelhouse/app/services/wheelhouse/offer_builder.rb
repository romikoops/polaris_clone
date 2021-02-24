# frozen_string_literal: true

module Wheelhouse
  class OfferBuilder
    attr_reader :results

    def self.offer(results:)
      new(results: results).perform
    end

    def initialize(results:)
      @results = results
    end

    def perform
      existing_offer || new_offer
    end

    private

    def new_offer
      Journey::Offer.create(query: results.first.query, line_item_sets: line_item_sets).tap do |created_offer|
        generate_pdf(offer: created_offer)
        publish_event(created_offer: created_offer)
      end
    end

    def existing_offer
      raw_query = "SELECT offer_id
      FROM journey_offer_line_item_sets
      JOIN journey_offers on journey_offer_line_item_sets.offer_id = journey_offers.id
      WHERE line_item_set_id IN (:line_item_set_ids)
      AND journey_offers.query_id = :query_id
      GROUP BY journey_offer_line_item_sets.id
      HAVING COUNT(DISTINCT line_item_set_id) = :result_count"

      sanitized_query = ActiveRecord::Base.sanitize_sql_array(
        [raw_query, binds]
      )
      Journey::Offer.find_by(
        id: ActiveRecord::Base.connection.exec_query(sanitized_query).to_a.pluck("offer_id").first
      )
    end

    def binds
      {line_item_set_ids: line_item_sets.map(&:id), result_count: results.count, query_id: results.first.query.id}
    end

    def line_item_sets
      @line_item_sets ||= results.map { |result| result.line_item_sets.order(created_at: :desc).first }
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
