# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Overlaps::ExtendsPastExisting do
  include_context "with standard trucking setup"

  let!(:trucking) do
    FactoryBot.create(:trucking_trucking,
      organization: organization,
      hub: hub,
      group: default_group,
      tenant_vehicle: tenant_vehicle,
      validity: validity)
  end
  let(:validity) { Range.new(Time.zone.today, 6.months.from_now.to_date, exclude_end: true) }
  let(:default_group) { FactoryBot.create(:groups_group, organization: organization, name: "default") }
  let(:arguments) do
    trucking.as_json.slice(
      "hub_id",
      "carriage",
      "load_type",
      "cargo_class",
      "organization_id",
      "truck_type",
      "group_id",
      "tenant_vehicle_id"
    ).merge(effective_date: start_date, expiration_date: end_date)
      .symbolize_keys
  end
  let(:ante_trucking) { Range.new(Time.zone.today, 2.months.from_now.to_date, exclude_end: true) }

  before { described_class.new(model: Trucking::Trucking, arguments: arguments).perform }

  describe ".perform" do
    context "when the new extends past the old" do
      let(:start_date) { 2.months.from_now.to_date }
      let(:end_date) { 9.months.from_now.to_date }

      it "detects the overlap and adjusts the old validity" do
        expect(trucking.reload.validity).to eq(ante_trucking)
      end
    end
  end
end
