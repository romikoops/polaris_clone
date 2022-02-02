# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Overlaps::Detector do
  let(:result) { described_class.overlaps(table: "pricings_pricings", arguments: arguments) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:pricing) do
    FactoryBot.create(:pricings_pricing,
      organization: organization,
      group: default_group,
      effective_date: DateTime.parse("2021/02/01"),
      expiration_date: DateTime.parse("2021/02/28").end_of_day,
      validity: validity)
  end
  let(:validity) { Range.new(Date.parse("2021/02/01"), Date.parse("2021/03/01"), exclude_end: true) }
  let(:start_date) { Date.parse("2021/02/01") }
  let(:end_date) { Date.parse("2021/02/28") }
  let(:default_group) { FactoryBot.create(:groups_group, organization: organization, name: "default") }
  let(:arguments) do
    pricing.slice("itinerary_id", "cargo_class", "organization_id", "group_id", "tenant_vehicle_id")
      .merge(effective_date: start_date, expiration_date: end_date)
      .symbolize_keys
  end

  let(:errors) { result.errors }

  Timecop.freeze(Date.parse("2021/01/01")) do
    describe "#validate" do
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
        let(:start_date) { Date.parse("2021/01/10") }
        let(:end_date) { Date.parse("2021/03/10") }
        let(:expected_result) { ["contained_by_new"] }

        it_behaves_like "a successful validation"
      end

      context "when the date is contained_by_existing" do
        let(:start_date) { Date.parse("2021/02/10") }
        let(:end_date) { Date.parse("2021/02/20") }
        let(:expected_result) { ["contained_by_existing"] }

        it_behaves_like "a successful validation"
      end

      context "when the date is extends_past_existing" do
        let(:start_date) { Date.parse("2021/02/10") }
        let(:end_date) { Date.parse("2021/04/20") }
        let(:expected_result) { ["extends_past_existing"] }

        it_behaves_like "a successful validation"
      end

      context "when the dates touch but dont overlap" do
        let(:start_date) { Date.parse("2021/03/01") }
        let(:end_date) { Date.parse("2021/04/10") }
        let(:expected_result) { [] }

        it_behaves_like "a successful validation"
      end

      context "when straddling two existing pricing sets" do
        let(:start_date) { Date.parse("2021/02/10") }
        let(:end_date) { Date.parse("2021/03/10") }
        let(:expected_result) { %w[extends_past_existing extends_before_existing] }

        before do
          pricing.dup.tap do |new_pricing|
            new_pricing.update(
              effective_date: DateTime.parse("2021/03/01"),
              expiration_date: DateTime.parse("2021/05/01").end_of_day,
              validity: Range.new(Date.parse("2021/03/01"), Date.parse("2021/05/01"), exclude_end: true)
            )
          end
        end

        it_behaves_like "a successful validation"
      end
    end
  end
end
