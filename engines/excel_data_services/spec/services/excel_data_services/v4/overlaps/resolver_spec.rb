# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Overlaps::Resolver do
  include_context "V4 setup"
  let!(:pricing) do
    FactoryBot.create(:pricings_pricing,
      organization: organization,
      group: default_group,
      effective_date: validity.first,
      expiration_date: (validity.last - 1.day).end_of_day,
      validity: validity)
  end
  let(:validity) { Range.new(Time.zone.tomorrow.to_date, 6.months.from_now.to_date, exclude_end: true) }
  let(:rows) do
    [
      pricing.slice(*conflict_keys).merge("effective_date" => start_date, "expiration_date" => end_date, "row" => 1)
    ]
  end
  let(:conflict_keys) { %w[itinerary_id cargo_class organization_id group_id tenant_vehicle_id] }
  let(:pricings) { Pricings::Pricing.all }
  let(:results) { described_class.state(state: state_arguments, model: Pricings::Pricing, keys: conflict_keys) }

  describe "#perform" do
    context "when the date matches exactly" do
      let(:start_date) { Time.zone.tomorrow.to_date }
      let(:end_date) { 6.months.from_now.to_date }

      it "detects the overlap and soft deletes the existing pricing", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(pricings.count).to eq(0)
      end
    end

    context "when contained_by_new" do
      let(:validity) { Range.new(1.month.from_now.to_date, 2.months.from_now, exclude_end: true) }
      let(:start_date) { Time.zone.tomorrow.to_date }
      let(:end_date) { 4.months.from_now.to_date }

      it "detects the overlap and soft deletes the existing pricing", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(pricings.count).to eq(0)
      end
    end

    context "when the date is contained_by_existing" do
      let(:validity) { Range.new(Time.zone.tomorrow.to_date, 4.months.from_now.to_date, exclude_end: true) }
      let(:start_date) { 1.month.from_now.to_date }
      let(:end_date) { 3.months.from_now.to_date }
      let(:expected_validities) do
        [
          Range.new(Time.zone.tomorrow.to_date, start_date, exclude_end: true)
        ]
      end

      it "splits the existing pricing validity around the set dates", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(pricings.pluck(:validity)).to match_array(expected_validities)
      end
    end

    context "when the date is extends_past_existing" do
      let(:validity) { Range.new(Time.zone.tomorrow.to_date, 2.months.from_now, exclude_end: true) }
      let(:start_date) { 1.month.from_now.to_date }
      let(:end_date) { 4.months.from_now.to_date }
      let(:expected_validities) do
        [
          Range.new(Time.zone.tomorrow.to_date, 1.month.from_now.to_date, exclude_end: true)
        ]
      end

      it "detects the overlap and updates the existing pricing validity", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(pricings.count).to eq(1)
        expect(pricings.pluck(:validity)).to match_array(expected_validities)
      end
    end

    context "when straddling two existing pricing sets" do
      let(:validity) { Range.new(Time.zone.tomorrow.to_date, 2.months.from_now, exclude_end: true) }
      let(:start_date) { 1.month.from_now.to_date }
      let(:end_date) { 4.months.from_now.to_date }
      let(:expected_validities) do
        [
          Range.new(Time.zone.tomorrow.to_date, 1.month.from_now.to_date, exclude_end: true)
        ]
      end

      before do
        pricing.dup.tap do |new_pricing|
          future_validity = Range.new(2.months.from_now, 5.months.from_now, exclude_end: true)
          new_pricing.update(
            effective_date: future_validity.first,
            expiration_date: (future_validity.last - 1.day).end_of_day,
            validity: future_validity
          )
        end
      end

      it "detects the overlap and updates the existing pricing validity, deleting the future one", :aggregate_failures do
        expect(results.errors).to be_empty
        expect(pricings.pluck(:validity)).to match_array(expected_validities)
      end
    end

    context "when conflict exists in the sheet" do
      let(:start_date) { 1.month.from_now.to_date }
      let(:end_date) { 4.months.from_now.to_date }
      let(:rows) do
        [
          pricing.slice(*conflict_keys)
            .merge("effective_date" => start_date, "expiration_date" => end_date, "row" => 1),
          pricing.slice(*conflict_keys)
            .merge("effective_date" => end_date - 5.days, "expiration_date" => end_date + 30.days, "row" => 2)
        ]
      end

      it "detects the overlap and updates the existing pricing validity", :aggregate_failures do
        expect(results.errors).to be_present
      end
    end
  end

  context "when a conflict exists in the sheet" do
    let(:start_date) { 1.month.from_now.to_date }
    let(:end_date) { 4.months.from_now.to_date }
    let(:rows) do
      [
        pricing.slice(*conflict_keys)
          .merge("effective_date" => start_date, "expiration_date" => end_date, "row" => 1),
        pricing.slice(*conflict_keys)
          .merge("effective_date" => end_date - 5.days, "expiration_date" => end_date + 30.days, "row" => 2)
      ]
    end

    it "detects the overlap and adds an error to the state", :aggregate_failures do
      expect(results.errors.map(&:reason)).to match_array(["The rows listed have conflicting validity dates. Please correct before reuploading."])
      expect(results.errors.map(&:row_nr)).to match_array(["1, 2"])
    end
  end
end
