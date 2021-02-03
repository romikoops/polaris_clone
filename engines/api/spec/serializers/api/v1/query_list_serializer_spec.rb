# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::QueryListSerializer do
    include_context "journey_pdf_setup"
    let(:address) { FactoryBot.create(:legacy_address) }
    let(:nexus) { FactoryBot.create(:legacy_nexus) }
    let(:decorated_query) { Api::V1::QueryDecorator.new(query) }
    let(:serialized_query) { described_class.new(decorated_query).serializable_hash }
    let(:target) { serialized_query.dig(:data, :attributes) }

    it "returns the correct selected_date for the object passed" do
      expect(target[:selectedDate]).to eq(query.cargo_ready_date)
    end

    it "returns the correct user for the object passed" do
      expect(target[:user]).to be_a(Api::V1::UserSerializer)
    end

    context "with pre_carriage" do
      before do
        allow(decorated_query).to receive(:pickup_address).and_return(address)
      end

      it "returns the pickup address" do
        expect(target.dig(:origin)).to be_a(Api::V1::AddressSerializer)
      end
    end

    context "without pre_carriage" do
      before do
        allow(decorated_query).to receive(:pickup_address).and_return(nil)
        allow(decorated_query).to receive(:origin_nexus).and_return(nexus)
      end

      it "returns the pickup address" do
        expect(target.dig(:origin)).to be_a(Api::V1::NexusSerializer)
      end
    end

    context "with on_carriage" do
      before do
        allow(decorated_query).to receive(:delivery_address).and_return(address)
      end

      it "returns the pickup address" do
        expect(target.dig(:destination)).to be_a(Api::V1::AddressSerializer)
      end
    end

    context "without on_carriage" do
      before do
        allow(decorated_query).to receive(:delivery_address).and_return(nil)
        allow(decorated_query).to receive(:destination_nexus).and_return(nexus)
      end

      it "returns the pickup address" do
        expect(target.dig(:destination)).to be_a(Api::V1::NexusSerializer)
      end
    end
  end
end
