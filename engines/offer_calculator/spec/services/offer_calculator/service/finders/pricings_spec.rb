# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Finders::Pricings do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary_1) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:load_type) { "cargo_item" }
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: user, group: tapped_group)
    end
  end
  let(:shipment) { FactoryBot.create(:legacy_shipment, organization: organization, user: user, load_type: load_type) }
  let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id) }
  let(:trips) do
    [
      FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_1)
    ]
  end
  let(:schedules) { trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) } }
  let(:pricing_finder) { described_class.new(shipment: shipment, quotation: quotation, schedules: schedules) }
  let(:results) { pricing_finder.perform }

  before do
    Organizations.current_id = organization.id
  end

  describe ".perform" do
    context "when only one pricing available on one itinerary" do
      let!(:pricing) { FactoryBot.create(:lcl_pricing, itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_1) }

      it "returns the one pricing" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.first).to eq(pricing)
        end
      end
    end

    context "when only two pricings available on one itinerary" do
      let!(:pricing_1) { FactoryBot.create(:lcl_pricing, itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_1) }
      let!(:pricing_2) { FactoryBot.create(:lcl_pricing, itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_2) }
      let(:trips) do
        [
          FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_1),
          FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_2)
        ]
      end

      it "returns the one pricing" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(2)
          expect(results.pluck(:id)).to match_array([pricing_1, pricing_2].map(&:id))
        end
      end
    end

    context "when only two pricings available on one itinerary (groups)" do
      before { FactoryBot.create(:lcl_pricing, itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_1) }

      let!(:pricing) { FactoryBot.create(:lcl_pricing, itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_1, group_id: group.id) }

      it "returns the one pricing" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(1)
          expect(results.pluck(:id)).to match_array([pricing.id])
        end
      end
    end

    context "when only two pricings available on one itinerary (groups & dedicated_only)" do
      before do
        FactoryBot.create(:lcl_pricing, itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_1)
        FactoryBot.create(:organizations_scope, target: organization, content: {dedicated_pricings_only: true})
      end

      it "returns the no pricings" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(0)
        end
      end
    end

    context "when only two pricings available on one itinerary (groups & dedicated_only)" do
      before do
        FactoryBot.create(:lcl_pricing, itinerary: itinerary_1, organization: organization, group_id: group.id, tenant_vehicle: tenant_vehicle_1)
        FactoryBot.create(:lcl_pricing, itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_1, group_id: group.id)
        FactoryBot.create(:organizations_scope, target: organization, content: {dedicated_pricings_only: true})
      end

      it "returns the two pricings" do
        aggregate_failures do
          expect(results.count).to eq(2)
        end
      end
    end

    context "when only multiple cargo classes and pricings from differnet groups" do
      let(:other_group) do
        FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
          FactoryBot.create(:groups_membership, member: user, group: tapped_group)
        end
      end
      let(:load_type) { "container" }

      before do
        allow(shipment).to receive(:cargo_classes).and_return(["fcl_20", "fcl_40"])
        FactoryBot.create(:fcl_20_pricing, itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_1, group_id: group.id)
        FactoryBot.create(:fcl_40_pricing, itinerary: itinerary_1, organization: organization, group_id: other_group.id, tenant_vehicle: tenant_vehicle_1)
        FactoryBot.create(:organizations_scope, target: organization, content: {dedicated_pricings_only: true})
      end

      it "returns no pricings" do
        aggregate_failures do
          expect(results.count).to eq(0)
        end
      end
    end
  end
end
