# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Request do
  let(:params) do
    FactoryBot.build(:journey_request_params,
      :lcl,
      pickup_address: pickup_address,
      delivery_address: delivery_address,
      origin_hub: origin_hub,
      destination_hub: destination_hub)
  end
  let(:pickup_address) { nil }
  let(:delivery_address) { nil }
  let(:origin_hub) { nil }
  let(:destination_hub) { nil }
  let(:query) { FactoryBot.create(:journey_query) }
  let(:persist) { false }
  let(:request) { described_class.new(query: query, params: params, persist: persist) }

  describe ".load_type" do
    it "returns the load_type" do
      expect(request.load_type).to eq("cargo_item")
    end
  end

  describe ".pre_carriage?" do
    context "when there is pre carriage" do
      let(:pickup_address) { FactoryBot.create(:legacy_address) }

      it "returns true when there is pre carriage" do
        expect(request.pre_carriage?).to eq(true)
      end
    end

    context "when there is no pre carriage" do
      let(:origin_hub) { FactoryBot.create(:legacy_hub) }

      it "returns false when there is no pre carriage" do
        expect(request.pre_carriage?).to eq(false)
      end
    end
  end

  describe ".on_carriage?" do
    context "when there is on carriage" do
      let(:delivery_address) { FactoryBot.create(:legacy_address) }

      it "returns true when there is on carriage" do
        expect(request.on_carriage?).to eq(true)
      end
    end

    context "when there is no on carriage" do
      let(:destination_hub) { FactoryBot.create(:legacy_hub) }

      it "returns false when there is no on carriage" do
        expect(request.on_carriage?).to eq(false)
      end
    end
  end
end
