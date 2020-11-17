# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::DateOverlapConflicts::Truckings::Metadata do
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
  let(:start_date) { Time.zone.today }
  let(:end_date) { 6.months.from_now.to_date }
  let(:default_group) { FactoryBot.create(:groups_group, organization: organization, name: "default") }
  let(:frame_data) do
    [trucking.as_json.slice(
      "hub_id",
      "carriage",
      "load_type",
      "cargo_class",
      "organization_id",
      "truck_type",
      "group_id",
      "tenant_vehicle_id"
    ).merge("effective_date" => start_date, "expiration_date" => end_date)]
  end

  let(:frame) { Rover::DataFrame.new(frame_data) }
  let(:target_schema) { nil }
  let(:truckings) { Trucking::Trucking.all }
  let(:results) { described_class.state(state: combinator_arguments) }

  describe ".perform" do
    context "when the date matches exactly" do
      it "detects the overlap and soft deletes the existing trucking", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(truckings.count).to eq(0)
      end
    end

    context "when contained_by_new" do
      let(:start_date) { 1.month.ago.to_date }
      let(:end_date) { 9.months.from_now.to_date }

      it "detects the overlap and soft deletes the existing trucking", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(truckings.count).to eq(0)
      end
    end

    context "when the date is contained_by_existing" do
      let(:start_date) { Time.zone.tomorrow }
      let(:end_date) { 3.months.from_now.to_date }
      let(:expected_validities) do
        [
          Range.new(Time.zone.today, Time.zone.tomorrow, exclude_end: true),
          Range.new(end_date, 6.months.from_now.to_date, exclude_end: true)
        ]
      end

      it "splits the existing trucking validity around the set dates", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(truckings.count).to eq(2)
        expect(truckings.pluck(:validity)).to match_array(expected_validities)
      end
    end

    context "when the date is extends_past_existing" do
      let(:start_date) { Time.zone.tomorrow }
      let(:end_date) { 9.months.from_now.to_date }
      let(:expected_validities) do
        [
          Range.new(Time.zone.today, Time.zone.tomorrow, exclude_end: true)
        ]
      end

      it "detects the overlap and updates the existing trucking validity", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(truckings.count).to eq(1)
        expect(truckings.pluck(:validity)).to match_array(expected_validities)
      end
    end

    context "when straddling two existing trucking sets" do
      let(:start_date) { 5.months.from_now.to_date }
      let(:end_date) { 9.months.from_now.to_date }
      let(:expected_validities) do
        [
          Range.new(Time.zone.today, 5.months.from_now.to_date, exclude_end: true),
          Range.new(9.months.from_now.to_date, 1.year.from_now.to_date, exclude_end: true)
        ]
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

      it "detects the overlap and updates the existing trucking validity", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(truckings.count).to eq(2)
        expect(truckings.pluck(:validity)).to match_array(expected_validities)
      end
    end
  end
end
