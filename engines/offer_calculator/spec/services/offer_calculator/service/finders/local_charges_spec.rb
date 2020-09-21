# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Finders::LocalCharges do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary_1) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_1) { itinerary_1.origin_hub }
  let(:destination_1) { itinerary_1.destination_hub }
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
  let(:finder) { described_class.new(shipment: shipment, quotation: quotation, schedules: schedules) }
  let(:results) { finder.perform }

  describe ".perform" do
    context "when no local charges required" do
      before { FactoryBot.create(:legacy_local_charge, hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_1) }

      it "returns the one pricing" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(0)
        end
      end
    end

    context "when only origin local charge required on one itinerary" do
      let!(:local_charge) { FactoryBot.create(:legacy_local_charge, hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_1) }

      before { allow(shipment).to receive(:has_pre_carriage?).and_return(true) }

      it "returns the one pricing" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(1)
          expect(results.pluck(:id)).to match_array([local_charge].map(&:id))
        end
      end
    end

    context "when only origin local charge required, multiple tenant vehicles available" do
      let!(:local_charge) { FactoryBot.create(:legacy_local_charge, hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_1) }
      let!(:local_charge_2) { FactoryBot.create(:legacy_local_charge, hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_2) }
      let(:trips) do
        [
          FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_1),
          FactoryBot.create(:legacy_trip, itinerary: itinerary_1, tenant_vehicle: tenant_vehicle_2)
        ]
      end

      before { allow(shipment).to receive(:has_pre_carriage?).and_return(true) }

      it "returns the one pricing" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(2)
          expect(results.pluck(:id)).to match_array([local_charge, local_charge_2].map(&:id))
        end
      end
    end

    context "when both local charge required on one itinerary" do
      let!(:export) { FactoryBot.create(:legacy_local_charge, hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_1) }
      let!(:import) { FactoryBot.create(:legacy_local_charge, direction: "import", hub: destination_1, organization: organization, tenant_vehicle: tenant_vehicle_1) }

      before do
        allow(shipment).to receive(:has_pre_carriage?).and_return(true)
        allow(shipment).to receive(:has_on_carriage?).and_return(true)
      end

      it "returns the one pricing" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(2)
          expect(results.pluck(:id)).to match_array([import, export].map(&:id))
        end
      end
    end

    context "when both local charge required on one itinerary and one has a group" do
      let!(:export) { FactoryBot.create(:legacy_local_charge, hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_1, group_id: group.id) }
      let!(:import) { FactoryBot.create(:legacy_local_charge, direction: "import", hub: destination_1, organization: organization, tenant_vehicle: tenant_vehicle_1) }

      before do
        FactoryBot.create(:legacy_local_charge, hub: origin_1, organization: organization, tenant_vehicle: tenant_vehicle_1)
        allow(shipment).to receive(:has_pre_carriage?).and_return(true)
        allow(shipment).to receive(:has_on_carriage?).and_return(true)
      end

      it "returns the one pricing" do
        aggregate_failures do
          expect(results).to be_a(ActiveRecord::Relation)
          expect(results.count).to eq(2)
          expect(results.pluck(:id)).to match_array([import, export].map(&:id))
        end
      end
    end
  end
end
