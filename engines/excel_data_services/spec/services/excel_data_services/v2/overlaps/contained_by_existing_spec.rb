# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Overlaps::ContainedByExisting do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let!(:default_group) { FactoryBot.create(:groups_group, name: "default", organization: organization) }

  describe "#perform" do
    let(:validity) { Range.new(Time.zone.today, 6.months.from_now.to_date, exclude_end: true) }
    let(:start_date) { 2.months.from_now.to_date }
    let(:end_date) { 4.months.from_now.to_date }
    let(:new_validities) do
      [
        Range.new(validity.first, start_date, exclude_end: true),
        Range.new(end_date, validity.last, exclude_end: true)
      ]
    end

    shared_examples_for "ContainedByExisting Conflict" do
      before { described_class.new(model: model, arguments: arguments).perform }

      it "detects the overlap, splitting the conflict to make a gap for the new validity", :aggregate_failures do
        expect(model.count).to eq(2)
        expect(model.pluck(:validity)).to match_array(new_validities)
      end
    end

    context "when the model is Trucking::Trucking" do
      include_context "with standard trucking setup"
      let(:model) { Trucking::Trucking }
      let!(:trucking) do
        FactoryBot.create(:trucking_trucking,
          organization: organization,
          hub: hub,
          group: default_group,
          tenant_vehicle: tenant_vehicle,
          validity: validity)
      end

      let(:arguments) do
        trucking.slice(
          :hub_id,
          :carriage,
          :load_type,
          :cargo_class,
          :organization_id,
          :truck_type,
          :group_id,
          :tenant_vehicle_id
        ).merge(effective_date: start_date, expiration_date: end_date)
          .symbolize_keys
      end

      it_behaves_like "ContainedByExisting Conflict"
    end

    context "when the model is Pricings::Pricing" do
      let(:model) { Pricings::Pricing }
      let!(:pricing) do
        FactoryBot.create(:pricings_pricing,
          organization: organization,
          group: default_group,
          tenant_vehicle: tenant_vehicle,
          effective_date: Time.zone.today,
          expiration_date: (6.months.from_now - 1.day).end_of_day)
      end

      let(:arguments) do
        pricing.slice(
          :itinerary_id, :cargo_class, :organization_id, :group_id, :tenant_vehicle_id
        ).merge(effective_date: start_date, expiration_date: end_date)
          .symbolize_keys
      end

      it_behaves_like "ContainedByExisting Conflict"
    end
  end
end
