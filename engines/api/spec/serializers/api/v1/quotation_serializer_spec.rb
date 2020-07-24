# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::QuotationSerializer do
    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }
    let(:charge_category) { FactoryBot.create(:bas_charge) }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
    let(:trip) { FactoryBot.create(:legacy_trip, vessel: "Cap San Diego", itinerary: itinerary) }
    let(:shipment) {
      FactoryBot.create(:legacy_shipment,
        with_full_breakdown: true,
        with_tenders: true,
        load_type: load_type,
        trip: trip,
        organization_id: organization.id,
        user: user)
    }
    let(:load_type) { "container" }
    let(:quotation) { Quotations::Quotation.find_by(legacy_shipment: shipment) }
    let(:default_scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
    let(:decorated_quotation) { Api::V1::QuotationDecorator.new(quotation, context: {scope: default_scope}) }
    let(:serialized_quotation) { described_class.new(decorated_quotation, params: {scope: default_scope}).serializable_hash }
    let(:target) { serialized_quotation.dig(:data, :attributes) }

    before do
      Organizations.current_id = organization.id
    end

    context "without a legacy shipment fcl" do
      before { quotation.update(legacy_shipment_id: nil) }

      it "return and empty array for containers" do
        expect(target[:containers]).to be_a(Api::V1::ContainerSerializer)
      end
    end

    context "without a legacy shipment lcl" do
      let(:load_type) { "cargo_item" }

      before { quotation.update(legacy_shipment_id: nil) }

      it "return and empty array for cargo_items" do
        expect(target[:cargoItems]).to be_a(Api::V1::CargoItemSerializer)
      end
    end
  end
end
