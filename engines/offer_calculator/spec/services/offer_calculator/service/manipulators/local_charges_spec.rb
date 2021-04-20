# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Manipulators::LocalCharges do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:other_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "second", organization: organization) }
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
      FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
    ]
  end
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |group|
      FactoryBot.create(:groups_membership, member: user, group: group)
    end
  end
  let(:schedules) { trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) } }
  let(:results) do
    described_class.results(association: Legacy::LocalCharge.all, request: request, schedules: schedules)
  end

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:export_margin,
      default_for: "local_charge", organization: organization, applicable: organization, value: 0)
    FactoryBot.create(:import_margin,
      default_for: "local_charge", organization: organization, applicable: organization, value: 0)
  end

  describe ".perform" do
    context "when only one local_charge available w/o margins" do
      let!(:local_charge) do
        FactoryBot.create(:legacy_local_charge,
          direction: "import", hub: itinerary.origin_hub, organization: organization,
          tenant_vehicle: tenant_vehicle)
      end

      it "returns the one local_charge" do
        results
        aggregate_failures do
          expect(results.first).to be_a(Pricings::ManipulatorResult)
          expect(results.first.id).to eq(local_charge.id)
        end
      end
    end

    context "when only two local_charges w/o margins" do
      let!(:local_charge) do
        FactoryBot.create(:legacy_local_charge,
          hub: itinerary.origin_hub, organization: organization, tenant_vehicle: tenant_vehicle)
      end
      let!(:other_local_charge) do
        FactoryBot.create(:legacy_local_charge,
          hub: itinerary.origin_hub, organization: organization, tenant_vehicle: other_tenant_vehicle)
      end
      let(:trips) do
        [
          FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle),
          FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: other_tenant_vehicle)
        ]
      end

      it "returns both local charges" do
        aggregate_failures do
          expect(results.first).to be_a(Pricings::ManipulatorResult)
          expect(results.count).to eq(2)
          expect(results.map(&:id)).to match_array([local_charge, other_local_charge].map(&:id))
        end
      end
    end

    context "when only two pricings w/ one margin (groups)" do
      let!(:local_charge) do
        FactoryBot.create(:legacy_local_charge,
          hub: itinerary.origin_hub, organization: organization, tenant_vehicle: tenant_vehicle, group_id: group.id)
      end
      let!(:margin) do
        FactoryBot.create(:export_margin,
          tenant_vehicle: tenant_vehicle, organization: organization, applicable: user, value: 100)
      end

      it "returns the one local_charge", :aggregate_failures do
        expect(results.first).to be_a(Pricings::ManipulatorResult)
        expect(results.count).to eq(1)
        expect(results.first.id).to eq(local_charge.id)
        expect(results.first.breakdowns.count).to eq(2)
        expect(results.first.breakdowns.second.source).to eq(margin)
      end
    end

    context "with invalid direction" do
      before do
        FactoryBot.create(:legacy_local_charge,
          direction: "blue", hub: itinerary.origin_hub, organization: organization,
          tenant_vehicle: tenant_vehicle, group_id: group.id)
      end

      it "raises InvalidDirection error" do
        expect { results }.to raise_error(OfferCalculator::Errors::InvalidDirection)
      end
    end
  end
end
