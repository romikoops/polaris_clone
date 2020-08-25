# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::QuotationSerializer do
    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }
    let(:charge_category) { FactoryBot.create(:bas_charge) }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
    let(:trip) { FactoryBot.create(:legacy_trip, vessel: "Cap San Diego", itinerary: itinerary) }
    let(:shipment) do
      FactoryBot.create(:legacy_shipment,
        with_full_breakdown: true,
        with_tenders: true,
        load_type: load_type,
        trip: trip,
        organization_id: organization.id,
        user: user)
    end
    let(:load_type) { "container" }
    let(:quotation) { FactoryBot.create(:quotations_quotation, organization: organization, legacy_shipment_id: nil) }
    let(:default_scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
    let(:decorated_quotation) { Api::V1::QuotationDecorator.new(quotation, context: {scope: default_scope}) }
    let(:serialized_quotation) { described_class.new(decorated_quotation, params: {scope: default_scope}).serializable_hash }
    let(:target) { serialized_quotation.dig(:data, :attributes) }
    let(:serialized_containers) { target[:containers].as_json }
    let(:serialized_cargo_items) { target[:cargoItems].as_json }
    let(:cargo) { FactoryBot.create(:cargo_cargo, quotation_id: quotation.id) }

    before do
      Organizations.current_id = organization.id
      FactoryBot.create(:quotations_tender, quotation: quotation, load_type: load_type)
    end

    context "without a legacy shipment fcl" do
      before do
        FactoryBot.create(:fcl_20_unit,
          cargo: cargo,
          weight_value: 1000,
          legacy: shipment.containers.first)
        FactoryBot.create(:legacy_container)
      end

      it "return an array of serialized containers", :aggregate_failures do
        expect(target[:containers]).to be_a(Api::V1::ContainerSerializer)
        expect(serialized_containers.dig("data").pluck("id")).to match_array([shipment.containers.first.id.to_s])
      end
    end

    context "without a legacy shipment lcl" do
      let(:load_type) { "cargo_item" }

      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          legacy: shipment.cargo_items.first)
        FactoryBot.create(:legacy_cargo_item)
      end

      it "return an array of serialized cargo_items", :aggregate_failures do
        expect(target[:cargoItems]).to be_a(Api::V1::CargoItemSerializer)
        expect(serialized_cargo_items.dig("data").pluck("id")).to match_array([shipment.cargo_items.first.id.to_s])
      end
    end
  end
end
