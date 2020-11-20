# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::ItinerarySerializer do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization_id: organization.id) }
    let(:serialized_itinerary) { described_class.new(itinerary).serializable_hash }
    let(:target) { serialized_itinerary.dig(:data, :attributes) }

    it "returns the correct name for the object passed" do
      expect(target[:name]).to eq("Gothenburg - Shanghai")
    end

    it "returns the correct mode_of_transport for the object passed" do
      expect(target[:modeOfTransport]).to eq("ocean")
    end
  end
end
