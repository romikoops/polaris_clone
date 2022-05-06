# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Overlaps::Detector do
  let(:result) { described_class.overlaps(table: record.class.table_name, arguments: arguments) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:record) do
    FactoryBot.create(:pricings_pricing,
      organization: organization,
      group: default_group,
      effective_date: DateTime.parse("2021/02/01"),
      expiration_date: DateTime.parse("2021/02/28").end_of_day,
      validity: validity)
  end
  let(:validity) { Range.new(Date.parse("2021/02/01"), Date.parse("2021/03/01"), exclude_end: true) }
  let(:start_date) { DateTime.parse("2021/02/01") }
  let(:end_date) { DateTime.parse("2021/02/28") }
  let(:default_group) { FactoryBot.create(:groups_group, organization: organization, name: "default") }
  let(:arguments) do
    record.slice(*conflict_keys)
      .merge(effective_date: start_date, expiration_date: end_date)
      .symbolize_keys
  end
  let(:conflict_keys) { %w[itinerary_id cargo_class organization_id group_id tenant_vehicle_id] }

  let(:errors) { result.errors }

  Timecop.freeze(DateTime.parse("2021/01/01")) do
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
        let(:start_date) { DateTime.parse("2021/01/10") }
        let(:end_date) { DateTime.parse("2021/03/10") }
        let(:expected_result) { ["contained_by_new"] }

        it_behaves_like "a successful validation"
      end

      context "when the date is contained_by_existing" do
        let(:start_date) { DateTime.parse("2021/02/10") }
        let(:end_date) { DateTime.parse("2021/02/20") }
        let(:expected_result) { ["contained_by_existing"] }

        it_behaves_like "a successful validation"
      end

      context "when the date is extends_past_existing" do
        let(:start_date) { DateTime.parse("2021/02/10") }
        let(:end_date) { DateTime.parse("2021/04/20") }
        let(:expected_result) { ["extends_past_existing"] }

        it_behaves_like "a successful validation"
      end

      context "when the dates touch but dont overlap" do
        let(:start_date) { DateTime.parse("2021/03/01") }
        let(:end_date) { DateTime.parse("2021/04/10") }
        let(:expected_result) { [] }

        it_behaves_like "a successful validation"
      end

      context "when straddling two existing pricing sets" do
        let(:start_date) { DateTime.parse("2021/02/10") }
        let(:end_date) { DateTime.parse("2021/03/10") }
        let(:expected_result) { %w[extends_past_existing extends_before_existing] }

        before do
          record.dup.tap do |new_pricing|
            new_pricing.update(
              effective_date: DateTime.parse("2021/03/01"),
              expiration_date: DateTime.parse("2021/05/01").end_of_day,
              validity: Range.new(Date.parse("2021/03/01"), Date.parse("2021/05/01"), exclude_end: true)
            )
          end
        end

        it_behaves_like "a successful validation"
      end

      context "when comparing LocalCharges and counterpart_hub_id is nil" do
        let(:record) do
          FactoryBot.create(:legacy_local_charge,
            organization: organization,
            group: default_group,
            effective_date: DateTime.parse("2021/02/01"),
            expiration_date: DateTime.parse("2021/02/28").end_of_day,
            validity: validity)
        end

        let(:conflict_keys) { %w[hub_id counterpart_hub_id tenant_vehicle_id load_type mode_of_transport group_id direction organization_id] }
        let(:expected_result) { ["contained_by_new"] }

        it_behaves_like "a successful validation"
      end
    end
  end
end
