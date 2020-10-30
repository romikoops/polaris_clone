# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::DateOverlapConflicts::Conflicts do
  include_context "with standard trucking setup"

  let(:result) { described_class.conflicts(table: "trucking_truckings", arguments: arguments) }

  let!(:trucking) do
    FactoryBot.create(:trucking_trucking,
      organization: organization,
      hub: hub,
      group: default_group,
      tenant_vehicle: tenant_vehicle,
      validity: validity)
  end
  let(:validity) { Range.new(Time.zone.today, 6.months.from_now.to_date, exclude_end: true) }
  let(:start_date) { Time.zone.today }
  let(:end_date) { 6.months.from_now.to_date }
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

  let(:errors) { result.errors }

  describe ".validate" do
    context "when the date matches exactly" do
      let(:expected_result) do
        {
          "contained_by_existing" => false,
          "extends_past_existing" => false,
          "extends_before_existing" => false,
          "contained_by_new" => true
        }
      end

      it "detects the overlap" do
        expect(result).to eq(expected_result)
      end
    end

    context "when contained_by_new" do
      let(:start_date) { 1.month.ago.to_date }
      let(:end_date) { 9.months.from_now.to_date }
      let(:expected_result) do
        {
          "contained_by_existing" => false,
          "extends_past_existing" => false,
          "extends_before_existing" => false,
          "contained_by_new" => true
        }
      end

      it "detects the overlap" do
        expect(result).to eq(expected_result)
      end
    end

    context "when the date is contained_by_existing" do
      let(:start_date) { Time.zone.tomorrow }
      let(:end_date) { 3.months.from_now.to_date }
      let(:expected_result) do
        {
          "contained_by_existing" => true,
          "extends_past_existing" => false,
          "extends_before_existing" => false,
          "contained_by_new" => false
        }
      end

      it "detects the overlap" do
        expect(result).to eq(expected_result)
      end
    end

    context "when the date is extends_past_existing" do
      let(:start_date) { Time.zone.tomorrow }
      let(:end_date) { 9.months.from_now.to_date }
      let(:expected_result) do
        {
          "contained_by_existing" => false,
          "extends_past_existing" => true,
          "extends_before_existing" => false,
          "contained_by_new" => false
        }
      end

      it "detects the overlap" do
        expect(result).to eq(expected_result)
      end
    end

    context "when straddling two existing trucking sets" do
      let(:start_date) { 5.months.from_now.to_date }
      let(:end_date) { 9.months.from_now.to_date }
      let(:expected_result) do
        {
          "contained_by_existing" => false,
          "extends_past_existing" => true,
          "extends_before_existing" => true,
          "contained_by_new" => false
        }
      end

      before do
        FactoryBot.create(:trucking_trucking,
          organization: organization,
          hub: hub,
          group: default_group,
          tenant_vehicle: tenant_vehicle,
          location: trucking.location,
          validity: Range.new(6.months.from_now.to_date, 1.year.from_now.to_date, exclude_end: true))
      end

      it "detects the overlap" do
        expect(result).to eq(expected_result)
      end
    end
  end
end
