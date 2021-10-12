# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::QueryDecorator do
  include_context "journey_pdf_setup"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
  let(:decorated_query) { described_class.new(query, context: { scope: scope }) }

  describe ".modes_of_transport" do
    before { FactoryBot.create(:journey_route_section, result: result, mode_of_transport: "air") }

    it "returns the unique mode_of_transport values excluding relay and carriage" do
      expect(decorated_query.modes_of_transport).to match_array(%w[ocean air])
    end
  end

  describe ".offer_id" do
    let!(:offer) { FactoryBot.create(:journey_offer, query: query, line_item_sets: [line_item_set]) }

    it "returns the unique mode_of_transport values excluding relay and carriage" do
      expect(decorated_query.offer_id).to eq(offer.id)
    end
  end

  describe "#completed" do
    let(:query) { FactoryBot.create(:journey_query, organization: organization, status: status) }

    context "when the status is 'completed'" do
      let(:status) { "completed" }

      it "returns true" do
        expect(decorated_query.completed).to eq(true)
      end
    end

    context "when the status is 'running'" do
      let(:status) { "running" }

      it "returns false" do
        expect(decorated_query.completed).to eq(false)
      end
    end
  end
end
