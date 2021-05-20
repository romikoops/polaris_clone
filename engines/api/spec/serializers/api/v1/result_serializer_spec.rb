# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::ResultSerializer do
    include_context "journey_pdf_setup"
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:decorated_result) { Api::V1::ResultDecorator.new(result, context: { scope: Organizations::DEFAULT_SCOPE }) }
    let(:serialized_result) { described_class.new(decorated_result, params: { scope: Organizations::DEFAULT_SCOPE }).serializable_hash }
    let(:target) { serialized_result.dig(:data, :attributes) }

    context "with pre and on carriage" do
      it "returns the pickup address of the Result" do
        expect(target[:pickupAddress]).to eq(pickup_point.name)
      end

      it "returns the delivery address of the Result" do
        expect(target[:deliveryAddress]).to eq(delivery_point.name)
      end
    end

    context "without pre and on carriage" do
      let(:route_sections) { [freight_section] }

      it "returns the pickup address of the Result" do
        expect(target[:pickupAddress]).to eq(nil)
      end

      it "returns the delivery address of the Result" do
        expect(target[:deliveryAddress]).to eq(nil)
      end
    end

    it "returns the origin hub name for the Result in question" do
      expect(target[:originHub]).to eq(decorated_result.origin)
    end

    it "returns the destination hub name for the Result in question" do
      expect(target[:destinationHub]).to eq(decorated_result.destination)
    end
  end
end
