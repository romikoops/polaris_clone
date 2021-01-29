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
      generate_pdf
      publish_event
      offer
    end

    def offer
      @offer ||= existing_offer || Journey::Offer.create(query: results.first.query, results: results)
    end

    private

    def existing_offer
      Journey::Offer.find_by(id: existing_offer_id)
    end

    def existing_offer_id
      raw_query = "SELECT offer_id
      FROM journey_offer_results
      JOIN journey_offers on journey_offer_results.offer_id = journey_offers.id
      WHERE result_id IN (:result_ids)
      AND journey_offers.query_id = :query_id
      GROUP BY journey_offer_results.id
      HAVING COUNT(DISTINCT result_id) = :result_count"

      sanitized_query = ActiveRecord::Base.sanitize_sql_array(
        [raw_query, {result_ids: results.map(&:id), result_count: results.count, query_id: results.first.query.id}]
      )
      ActiveRecord::Base.connection.exec_query(sanitized_query).to_a.first&.dig("offer_id")
    end

    def generate_pdf
      Pdf::Quotation::Client.new(offer: offer).file
    end

    def publish_event
      Rails.configuration.event_store.publish(
        Journey::OfferCreated.new(data: {
          offer: offer.to_global_id, organization_id: Organizations.current_id}),
        stream_name: "Organization$#{Organizations.current_id}"
      )
    end
  end
end
