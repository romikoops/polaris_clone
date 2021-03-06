# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Queries::ValidRoutes do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:itinerary2) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }
  let(:origin_hub1) { itinerary.origin_hub }
  let(:destination_hub1) { itinerary.destination_hub }
  let(:origin_hub2) { itinerary2.origin_hub }
  let(:destination_hub2) { itinerary2.destination_hub }
  let(:request) { FactoryBot.create(:offer_calculator_request, organization: organization, client: user, creator: user) }
  let(:current_etd) { 2.days.from_now }
  let(:tenant_vehicle1) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization, name: "1") }
  let(:tenant_vehicle2) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization, name: "2") }
  let(:scope) { Organizations::DEFAULT_SCOPE }
  let(:args) do
    {
      request: request,
      date_range: (Time.zone.now...Time.zone.now + 34.days),
      query: {
        origin_hub_ids: [origin_hub1.id, origin_hub2.id],
        destination_hub_ids: [destination_hub1.id, destination_hub2.id]
      },
      scope: scope
    }
  end
  let(:results) { described_class.new(args).perform }

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle1)
    FactoryBot.create(:legacy_trip, itinerary: itinerary2, tenant_vehicle: tenant_vehicle2)

    FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)

    allow(request).to receive(:cargo_classes).and_return(["lcl"])
    allow(request).to receive(:load_type).and_return("cargo_item")
    allow(request).to receive(:pre_carriage?).and_return(false)
    allow(request).to receive(:on_carriage?).and_return(false)
  end

  describe "#perform" do
    before do
      FactoryBot.create(:lcl_pricing,
        itinerary: itinerary, organization: organization, tenant_vehicle: tenant_vehicle1)
      FactoryBot.create(:lcl_pricing,
        itinerary: itinerary2, organization: organization, tenant_vehicle: tenant_vehicle2)
      FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, organization: organization)
      FactoryBot.create(:fcl_40_pricing, itinerary: itinerary, organization: organization)
      FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary, organization: organization)
    end

    shared_examples_for "all routes are excluded" do
      it "filters out all routes without the nec essary charges present and valid" do
        expect(results.length).to eq(0)
      end
    end

    shared_examples_for "all routes are included" do
      it "finds all routes without the neccessary charges present and valid", :aggregate_failures do
        expect(results.pluck("itinerary_id")).to match_array([itinerary.id, itinerary2.id])
        expect(results.pluck("tenant_vehicle_id")).to match_array([tenant_vehicle1.id, tenant_vehicle2.id])
      end
    end

    context "without carriage" do
      it_behaves_like "all routes are included"
    end

    context "with trucking and no local charges" do
      before do
        allow(request).to receive(:pre_carriage?).and_return(true)
        allow(request).to receive(:on_carriage?).and_return(true)
      end

      it_behaves_like "all routes are excluded"
    end

    context "with trucking and no local charges but local_charges_required_with_trucking is `false" do
      before do
        allow(request).to receive(:pre_carriage?).and_return(true)
        allow(request).to receive(:on_carriage?).and_return(true)
      end

      let(:scope) { { local_charges_required_with_trucking: false } }

      it_behaves_like "all routes are included"
    end

    context "with trucking and local charges" do
      before do
        FactoryBot.create(:legacy_local_charge,
          hub: origin_hub1, organization: organization, tenant_vehicle: tenant_vehicle1)
        allow(request).to receive(:pre_carriage?).and_return(true)
      end

      it "return the valid routes for cargo_item", :aggregate_failures do
        expect(results.pluck("itinerary_id")).to match_array([itinerary.id])
        expect(results.pluck("tenant_vehicle_id")).to match_array([tenant_vehicle1.id])
      end
    end

    context "with dedicated_pricings_only" do
      let(:scope) do
        { dedicated_pricings_only: true }.with_indifferent_access
      end
      let(:group) do
        FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
          FactoryBot.create(:groups_membership, member: user, group: tapped_group)
        end
      end

      before do
        allow(request).to receive(:pre_carriage?).and_return(false)
        allow(request).to receive(:on_carriage?).and_return(false)
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary, organization: organization, tenant_vehicle: tenant_vehicle1, group_id: group.id)
      end

      it "return the valid routes for cargo_item", :aggregate_failures do
        expect(results.pluck("itinerary_id")).to match_array([itinerary.id])
        expect(results.pluck("tenant_vehicle_id")).to match_array([tenant_vehicle1.id])
      end
    end
  end
end
