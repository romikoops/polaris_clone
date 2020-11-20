# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::QuotationListSerializer do
    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }
    let(:charge_category) { FactoryBot.create(:bas_charge) }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
    let(:trip) { FactoryBot.create(:legacy_trip, vessel: "Cap San Diego", itinerary: itinerary) }
    let(:shipment) {
      FactoryBot.create(:legacy_shipment,
        with_full_breakdown: true,
        with_tenders: true,
        trip: trip,
        organization_id: organization.id,
        user: user)
    }
    let(:quotation) { Quotations::Quotation.find_by(legacy_shipment: shipment) }
    let(:default_scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
    let(:decorated_quotation) { Api::V1::QuotationDecorator.new(quotation, context: {scope: default_scope}) }
    let(:serialized_quotation) {
      described_class.new(decorated_quotation, params: {scope: default_scope}).serializable_hash
    }
    let(:target) { serialized_quotation.dig(:data, :attributes) }

    before do
      Organizations.current_id = organization.id
    end

    context "without trucking" do
      it "returns the correct origin for the object passed", :aggregate_failures do
        expect(target[:origin]).to be_a(Api::V1::NexusSerializer)
        expect(target[:origin].to_hash.dig(:data, :id)).to eq(quotation.origin_nexus_id.to_s)
      end

      it "returns the correct destination for the object passed", :aggregate_failures do
        expect(target[:destination]).to be_a(Api::V1::NexusSerializer)
        expect(target[:destination].to_hash.dig(:data, :id)).to eq(quotation.destination_nexus_id.to_s)
      end
    end

    context "with trucking" do
      let(:pickup_address) { FactoryBot.create(:gothenburg_address) }
      let(:delivery_address) { FactoryBot.create(:shanghai_address) }

      before do
        allow(quotation).to receive(:pickup_address).and_return(pickup_address)
        allow(quotation).to receive(:delivery_address).and_return(delivery_address)
      end

      it "returns the correct origin for the object passed", :aggregate_failures do
        expect(target[:origin]).to be_a(Api::V1::AddressSerializer)
        expect(target[:origin].to_hash.dig(:data, :id)).to eq(pickup_address.id.to_s)
      end

      it "returns the correct destination for the object passed", :aggregate_failures do
        expect(target[:destination]).to be_a(Api::V1::AddressSerializer)
        expect(target[:destination].to_hash.dig(:data, :id)).to eq(delivery_address.id.to_s)
      end
    end

    it "returns the correct user for the object passed", :aggregate_failures do
      expect(target[:user]).to be_a(Api::V1::UserSerializer)
      expect(target[:user].to_hash.dig(:data, :id)).to eq(user.id.to_s)
    end

    it "returns the correct laod_type for the object passed" do
      expect(target[:loadType]).to eq(shipment.load_type)
    end

    it "returns the correct selected_date for the object passed" do
      expect(target[:selectedDate]).to eq(quotation.selected_date)
    end
  end
end
