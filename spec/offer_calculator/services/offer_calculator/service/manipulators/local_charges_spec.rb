# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Manipulators::LocalCharges do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary_1) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: "second", organization: organization) }
  let(:load_type) { "cargo_item" }
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
  let(:results) { described_class.results(association: Legacy::LocalCharge.all, shipment: shipment, schedules: schedules) }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:export_margin, default_for: "local_charge", organization: organization, applicable: organization, value: 0)
    FactoryBot.create(:import_margin, default_for: "local_charge", organization: organization, applicable: organization, value: 0)
  end

  describe ".perform" do
    context "when only one local_charge available w/o margins" do
      let!(:local_charge) { FactoryBot.create(:legacy_local_charge, direction: "import", hub: itinerary_1.origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1) }

      it "returns the one local_charge" do
        results
        aggregate_failures do
          expect(results.first).to be_a(Pricings::ManipulatorResult)
          expect(results.first.id).to eq(local_charge.id)
        end
      end
    end

    context "when only two local_charges w/o margins" do
      let!(:local_charge_1) { FactoryBot.create(:legacy_local_charge, hub: itinerary_1.origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1) }
      let!(:local_charge_2) { FactoryBot.create(:legacy_local_charge, hub: itinerary_1.origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_2) }
      let(:trips) do
        [
          FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_1),
          FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_2)
        ]
      end

      it "returns the one local_charge" do
        aggregate_failures do
          expect(results.first).to be_a(Pricings::ManipulatorResult)
          expect(results.count).to eq(2)
          expect(results.map(&:id)).to eq([local_charge_1, local_charge_2].map(&:id))
        end
      end
    end

    context "when only two pricings w/ one margin (groups)" do
      let!(:local_charge) { FactoryBot.create(:legacy_local_charge, hub: itinerary_1.origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1, group_id: group.id) }
      let!(:margin) { FactoryBot.create(:export_margin, tenant_vehicle: tenant_vehicle_1, organization: organization, applicable: user, value: 100) }

      it "returns the one local_charge" do
        aggregate_failures do
          expect(results.first).to be_a(Pricings::ManipulatorResult)
          expect(results.count).to eq(1)
          expect(results.first.id).to eq(local_charge.id)
          expect(results.first.breakdowns.count).to eq(2)
          expect(results.first.breakdowns.second.source).to eq(margin)
        end
      end
    end

    context "with invalid direction" do
      before { FactoryBot.create(:legacy_local_charge, direction: "blue", hub: itinerary_1.origin_hub, organization: organization, tenant_vehicle: tenant_vehicle_1, group_id: group.id) }

      it "raises InvalidDirection error" do
        expect { results }.to raise_error(OfferCalculator::Errors::InvalidDirection)
      end
    end
  end
end
