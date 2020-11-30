# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Manipulators::Truckings do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary_1) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: "second", organization: organization) }
  let(:load_type) { "cargo_item" }
  let(:origin_hub) { itinerary_1.origin_hub }
  let(:shipment) { FactoryBot.create(:legacy_shipment, organization: organization, user: user, load_type: load_type) }
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
    described_class.results(association: Trucking::Trucking.all, shipment: shipment, schedules: schedules)
  }

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:trucking_pre_margin,
      default_for: "trucking", organization: organization, applicable: organization, value: 0)
    FactoryBot.create(:trucking_on_margin,
      default_for: "trucking", organization: organization, applicable: organization, value: 0)
  end

  describe ".perform" do
    context "when only one trucking available w/o margins" do
      let!(:trucking) {
        FactoryBot.create(:trucking_trucking,
          carriage: "on", hub: origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1)
      }

      it "returns the one trucking" do
        results
        aggregate_failures do
          expect(results.first).to be_a(Pricings::ManipulatorResult)
          expect(results.first.id).to eq(trucking.id)
        end
      end
    end

    context "when only two truckings w/o margins" do
      let!(:trucking_1) {
        FactoryBot.create(:trucking_trucking,
          hub: origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1)
      }
      let!(:trucking_2) do
        FactoryBot.create(:trucking_trucking,
          hub: origin_hub,
          organization: organization,
          tenant_vehicle: tenant_vehicle_2,
          location: FactoryBot.create(:trucking_location, :with_location))
      end
      let(:trips) do
        [
          FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_1),
          FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_2)
        ]
      end

      it "returns the one trucking" do
        aggregate_failures do
          expect(results.first).to be_a(Pricings::ManipulatorResult)
          expect(results.count).to eq(2)
          expect(results.map(&:id)).to match_array([trucking_1, trucking_2].map(&:id))
        end
      end
    end

    context "when only two truckings w/ one margin (groups)" do
      let!(:trucking) {
        FactoryBot.create(:trucking_trucking,
          hub: origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1,
          group_id: group.id)
      }
      let!(:margin) {
        FactoryBot.create(:trucking_pre_margin, organization: organization,
                                                applicable: user, value: 100)
      }

      it "returns the one trucking" do
        aggregate_failures do
          expect(results.first).to be_a(Pricings::ManipulatorResult)
          expect(results.count).to eq(1)
          expect(results.first.id).to eq(trucking.id)
          expect(results.first.breakdowns.count).to eq(4)
          expect(results.first.breakdowns.map(&:source).compact.uniq).to eq([margin])
        end
      end
    end
  end
end
