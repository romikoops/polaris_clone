# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ResultSerializer do
    let(:journey_query) { FactoryBot.create(:journey_query) }
    let(:result) { FactoryBot.create(:journey_result, query_id: journey_query.id) }
    let(:decorated_result) { Api::V2::ResultDecorator.new(result) }
    let(:serialized_result) { described_class.new(decorated_result).serializable_hash }
    let(:target) { serialized_result.dig(:data, :attributes) }
    let(:routing_carrier) { FactoryBot.create(:routing_carrier) }

    before { allow(decorated_result).to receive(:routing_carrier).and_return(routing_carrier) }

    it "returns the correct modes of transport for the object passed" do
      expect(target[:modesOfTransport]).to eq(["ocean"])
    end

    it "returns the carrier logo" do
      expect(target[:carrierLogo]).to include(routing_carrier.logo.filename.to_s)
    end

    it "returns the transshipment" do
      expect(target[:transshipment]).to eq(decorated_result.main_freight_section.transshipment)
    end

    it "returns the number of stops" do
      expect(target[:numberOfStops]).to eq(0)
    end

    it "validates queryId is present in the serialized attributes" do
      expect(target[:queryId]).to be_present
    end

    context "when the result decorator's total returns nil" do
      it "returns nil values for a money representation" do
        allow(decorated_result).to receive(:total).and_return(nil)
        expect(target[:total]).to eq({ value: nil, currency: nil })
      end
    end

    it "returns a money representation when the total is present" do
      expect(target[:total]).to eq({ value: 36.00, currency: "EUR" })
    end
  end
end
