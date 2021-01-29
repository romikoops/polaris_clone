# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Manipulators::Pricings do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:itinerary_1) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: "second", organization: organization) }
  let(:load_type) { "cargo_item" }
  let(:request) do
    FactoryBot.create(:offer_calculator_request,
      organization: organization,
      client: user,
      creator: user,
      cargo_trait: :lcl)
  end
  let(:trips) do
    [
      FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_1)
    ]
  end
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |group|
      FactoryBot.create(:groups_membership, member: user, group: group)
    end
  end
  let(:schedules) { trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) } }
  let(:results) {
    described_class.results(association: Pricings::Pricing.all, request: request, schedules: schedules)
  }

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:freight_margin,
      default_for: "ocean", organization: organization, applicable: organization, value: 0)
  end

  describe ".perform" do
    context "when only one pricing available w/o margins" do
      let!(:pricing) {
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_1)
      }

      it "returns the one pricing" do
        results
        aggregate_failures do
          expect(results.first).to be_a(Pricings::ManipulatorResult)
          expect(results.first.id).to eq(pricing.id)
        end
      end
    end

    context "when only two pricings w/o margins" do
      let!(:pricing_1) {
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_1)
      }
      let!(:pricing_2) {
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_2)
      }
      let(:trips) do
        [
          FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_1),
          FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_2)
        ]
      end

      it "returns the one pricing" do
        aggregate_failures do
          expect(results.first).to be_a(Pricings::ManipulatorResult)
          expect(results.count).to eq(2)
          expect(results.map(&:id)).to eq([pricing_1, pricing_2].map(&:id))
        end
      end
    end

    context "when only two pricings w/ one margin (groups)" do
      let!(:pricing) {
        FactoryBot.create(:lcl_pricing,
          itinerary: itinerary_1, organization: organization, tenant_vehicle: tenant_vehicle_1, group_id: group.id)
      }
      let!(:margin) {
        FactoryBot.create(:freight_margin,
          pricing: pricing, organization: organization, applicable: user, value: 100)
      }

      it "returns the one pricing" do
        aggregate_failures do
          expect(results.first).to be_a(Pricings::ManipulatorResult)
          expect(results.count).to eq(1)
          expect(results.first.id).to eq(pricing.id)
          expect(results.first.breakdowns.count).to eq(2)
          expect(results.first.breakdowns.second.source).to eq(margin)
        end
      end
    end
  end
end
