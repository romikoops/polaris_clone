# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::CarrierSerializer do
    let(:carrier) { FactoryBot.create(:routing_carrier, with_logo: with_logo) }
    let(:serialized_carrier) { described_class.new(carrier).serializable_hash }
    let(:target) { serialized_carrier.dig(:data, :attributes) }

    context "with logo" do
      let(:with_logo) { true }

      it "returns the correct origin name for the object passed", :aggregate_failures do
        expect(target[:code]).to eq(carrier.code)
        expect(target[:name]).to eq(carrier.name)
        expect(target[:logo]).to include("test-image.jpg")
      end
    end

    context "without logo" do
      let(:with_logo) { false }

      it "returns the correct or  igin name for the object passed", :aggregate_failures do
        expect(target[:code]).to eq(carrier.code)
        expect(target[:name]).to eq(carrier.name)
        expect(target[:logo]).to be_nil
      end
    end
  end
end
