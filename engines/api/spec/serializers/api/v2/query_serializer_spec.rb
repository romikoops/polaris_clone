# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::QuerySerializer do
    include_context "journey_pdf_setup"
    let(:address) { FactoryBot.create(:legacy_address) }
    let(:nexus) { FactoryBot.create(:legacy_nexus) }
    let(:decorated_query) { Api::V2::QueryDecorator.new(query) }
    let(:serialized_query) { described_class.new(decorated_query).serializable_hash }
    let(:target) { serialized_query.dig(:data, :attributes) }
    let!(:offer) { FactoryBot.create(:journey_offer, query: query, line_item_sets: [line_item_set]) }
    let(:expected_serialized_query) do
      {
        id: query.id,
        billable: query.billable,
        originName: query.origin,
        destinationName: query.destination,
        reference: line_item_set.reference,
        modesOfTransport: decorated_query.modes_of_transport,
        loadType: decorated_query.load_type,
        offerId: offer.id,
        issueDate: query.created_at,
        originId: query.origin_geo_id,
        destinationId: query.destination_geo_id,
        parentId: nil,
        companyId: query.company_id,
        cargoReadyDate: query.cargo_ready_date,
        currency: query.currency
      }
    end

    it "returns the correct origin name for the object passed" do
      expect(target.except(:client)).to eq(expected_serialized_query)
    end

    it "returns the correct user for the object passed" do
      expect(target[:client]).to be_a(Api::V2::ClientSerializer)
    end
  end
end
