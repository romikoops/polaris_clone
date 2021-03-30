# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Overlaps::ContainedByExisting do
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
  let(:start_date) { 2.months.from_now.to_date }
  let(:end_date) { 4.months.from_now.to_date }
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
  let(:post_trucking) { Range.new(4.months.from_now.to_date, 6.months.from_now.to_date, exclude_end: true) }

  before { described_class.new(model: Trucking::Trucking, arguments: arguments).perform }

  describe ".perform" do
    it "detects the overlap", :aggregate_failures do
      expect(Trucking::Trucking.count).to eq(2)
      expect(Trucking::Trucking.all.map(&:validity)).to match_array([ante_trucking, post_trucking])
    end
  end
end
