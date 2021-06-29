# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Finders::Pricings do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:itinerary1) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:tenant_vehicle1) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:tenant_vehicle2) { FactoryBot.create(:legacy_tenant_vehicle, name: "second", organization: organization) }
  let(:load_type) { "cargo_item" }
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: user, group: tapped_group)
    end
  end
  let(:request) do
    FactoryBot.create(:offer_calculator_request,
      organization: organization,
      client: user,
      creator: user,
      cargo_trait: :lcl)
  end
  let(:trips) do
    [
      FactoryBot.create(:legacy_trip, itinerary: itinerary1, tenant_vehicle: tenant_vehicle1)
    ]
  end
  let(:schedules) { trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) } }
  let(:pricing_finder) { described_class.new(request: request, schedules: schedules) }
  let(:results) { pricing_finder.perform }

  before do
    Organizations.current_id = organization.id
  end

  describe ".perform" do
    context "when only one pricing available on one itinerary" do
      let!(:pricing) do
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary1, organization: organization, tenant_vehicle: tenant_vehicle1)
      end

      it "returns the one pricing", :aggregate_failures do
        expect(results).to be_a(ActiveRecord::Relation)
        expect(results.first).to eq(pricing)
      end
    end

    context "when only two pricings available on one itinerary" do
      let!(:pricing1) do
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary1, organization: organization, tenant_vehicle: tenant_vehicle1)
      end
      let!(:pricing2) do
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary1, organization: organization, tenant_vehicle: tenant_vehicle2)
      end
      let(:trips) do
        [
          FactoryBot.create(:legacy_trip, itinerary: itinerary1, tenant_vehicle: tenant_vehicle1),
          FactoryBot.create(:legacy_trip, itinerary: itinerary1, tenant_vehicle: tenant_vehicle2)
        ]
      end

      it "returns the one pricing", :aggregate_failures do
        expect(results).to be_a(ActiveRecord::Relation)
        expect(results.count).to eq(2)
        expect(results.pluck(:id)).to match_array([pricing1, pricing2].map(&:id))
      end
    end

    context "when only two pricings available on one itinerary (groups)" do
      before do
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary1, organization: organization, tenant_vehicle: tenant_vehicle1)
      end

      let!(:pricing) do
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary1, organization: organization, tenant_vehicle: tenant_vehicle1, group_id: group.id)
      end

      it "returns the one pricing", :aggregate_failures do
        expect(results).to be_a(ActiveRecord::Relation)
        expect(results.count).to eq(1)
        expect(results.pluck(:id)).to match_array([pricing.id])
      end
    end

    context "when no dedicated pricings available on one itinerary (groups & dedicated_only)" do
      before do
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary1, organization: organization, tenant_vehicle: tenant_vehicle1)
        organization.scope.update(content: { dedicated_pricings_only: true })
      end

      it "returns the no pricings", :aggregate_failures do
        expect(results).to be_a(ActiveRecord::Relation)
        expect(results.count).to eq(0)
      end
    end

    context "when only two pricings available on one itinerary (groups & dedicated_only)" do
      before do
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary1, organization: organization, group_id: group.id, tenant_vehicle: tenant_vehicle1)
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary1, organization: organization, tenant_vehicle: tenant_vehicle2, group_id: group.id)
        organization.scope.update(content: { dedicated_pricings_only: true })
      end

      let(:trips) do
        [
          FactoryBot.create(:legacy_trip, itinerary: itinerary1, tenant_vehicle: tenant_vehicle1),
          FactoryBot.create(:legacy_trip, itinerary: itinerary1, tenant_vehicle: tenant_vehicle2)
        ]
      end

      it "returns the two pricings", :aggregate_failures do
        expect(results.count).to eq(2)
      end
    end

    context "when only multiple cargo classes and pricings from different groups" do
      let(:other_group) do
        FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
          FactoryBot.create(:groups_membership, member: user, group: tapped_group)
        end
      end
      let(:load_type) { "container" }

      before do
        allow(request).to receive(:cargo_classes).and_return(%w[fcl_20 fcl_40])
        FactoryBot.create(:fcl_20_pricing,
          itinerary: itinerary1, organization: organization, tenant_vehicle: tenant_vehicle1, group_id: group.id)
        FactoryBot.create(:fcl_40_pricing,
          itinerary: itinerary1, organization: organization, group_id: other_group.id,
          tenant_vehicle: tenant_vehicle1)
        organization.scope.update(content: { dedicated_pricings_only: true })
      end

      it "returns no pricings", :aggregate_failures do
        expect(results.count).to eq(0)
      end
    end
  end
end
