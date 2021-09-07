# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Overlaps::Detector do
  let(:result) { described_class.overlaps(table: "pricings_pricings", arguments: arguments) }
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
  let(:arguments) do
    pricing.slice("itinerary_id", "cargo_class", "organization_id", "group_id", "tenant_vehicle_id")
      .merge(effective_date: start_date, expiration_date: end_date)
      .symbolize_keys
  end

  let(:errors) { result.errors }

  describe ".validate" do
    shared_examples_for "a successful validation" do
      it "detects the overlap, returning the expected result" do
        expect(result).to eq(expected_result)
      end
    end

    context "when the date matches exactly" do
      let(:expected_result) { ["contained_by_new"] }

      it_behaves_like "a successful validation"
    end

    context "when contained_by_new" do
      let(:start_date) { 1.month.ago.to_date }
      let(:end_date) { 9.months.from_now.to_date }
      let(:expected_result) { ["contained_by_new"] }

      it_behaves_like "a successful validation"
    end

    context "when the date is contained_by_existing" do
      let(:start_date) { Time.zone.tomorrow }
      let(:end_date) { 3.months.from_now.to_date }
      let(:expected_result) { ["contained_by_existing"] }

      it_behaves_like "a successful validation"
    end

    context "when the date is extends_past_existing" do
      let(:start_date) { Time.zone.tomorrow }
      let(:end_date) { 9.months.from_now.to_date }
      let(:expected_result) { ["extends_past_existing"] }

      it_behaves_like "a successful validation"
    end

    context "when straddling two existing pricing sets" do
      let(:start_date) { 5.months.from_now.to_date }
      let(:end_date) { 9.months.from_now.to_date }
      let(:expected_result) { %w[extends_past_existing extends_before_existing] }

      before do
        pricing.dup.tap do |new_pricing|
          new_pricing.update(
            effective_date: 6.months.from_now.to_date,
            expiration_date: (1.year.from_now.to_date - 1.day).end_of_day,
            validity: Range.new(6.months.from_now.to_date, 1.year.from_now.to_date, exclude_end: true)
          )
        end
      end

      it_behaves_like "a successful validation"
    end
  end
end
