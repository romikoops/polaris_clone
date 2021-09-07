# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Overlaps::Resolver do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:pricing) do
    FactoryBot.create(:pricings_pricing,
      organization: organization,
      group: default_group,
      effective_date: validity.first,
      expiration_date: (validity.last - 1.day).end_of_day,
      validity: validity)
  end
  let(:validity) { Range.new(Time.zone.today, 6.months.from_now.to_date, exclude_end: true) }
  let(:start_date) { Time.zone.today }
  let(:end_date) { 6.months.from_now.to_date }
  let(:default_group) { FactoryBot.create(:groups_group, organization: organization, name: "default") }
  let(:frame_data) do
    [
      pricing.slice(*conflict_keys)
        .merge("effective_date" => start_date, "expiration_date" => end_date)
    ]
  end
  let(:conflict_keys) { %w[itinerary_id cargo_class organization_id group_id tenant_vehicle_id effective_date expiration_date] }
  let(:frame) { Rover::DataFrame.new(frame_data) }
  let(:pricings) { Pricings::Pricing.all }
  let(:state) { instance_double("State", frame: frame, errors: [], failed?: false) }
  let(:results) { described_class.state(state: state, model: Pricings::Pricing, keys: conflict_keys) }

  describe "#perform" do
    context "when the date matches exactly" do
      it "detects the overlap and soft deletes the existing pricing", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(pricings.count).to eq(0)
      end
    end

    context "when contained_by_new" do
      let(:start_date) { 1.month.ago.to_date }
      let(:end_date) { 9.months.from_now.to_date }

      it "detects the overlap and soft deletes the existing pricing", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(pricings.count).to eq(0)
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

      it "splits the existing pricing validity around the set dates", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(pricings.count).to eq(2)
        expect(pricings.pluck(:validity)).to match_array(expected_validities)
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

      it "detects the overlap and updates the existing pricing validity", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(pricings.count).to eq(1)
        expect(pricings.pluck(:validity)).to match_array(expected_validities)
      end
    end

    context "when straddling two existing pricing sets" do
      let(:start_date) { 5.months.from_now.to_date }
      let(:end_date) { 9.months.from_now.to_date }
      let(:expected_validities) do
        [
          Range.new(Time.zone.today, 5.months.from_now.to_date, exclude_end: true),
          Range.new(9.months.from_now.to_date, 1.year.from_now.to_date, exclude_end: true)
        ]
      end

      before do
        pricing.dup.tap do |new_pricing|
          new_pricing.update(
            effective_date: 6.months.from_now.to_date,
            expiration_date: (1.year.from_now.to_date - 1.day).end_of_day,
            validity: Range.new(6.months.from_now.to_date, 1.year.from_now.to_date, exclude_end: true)
          )
        end
      end

      it "detects the overlap and updates the existing pricing validity", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(pricings.count).to eq(2)
        expect(pricings.pluck(:validity)).to match_array(expected_validities)
      end
    end
  end
end
