# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Overlaps::Clearer do
  include_context "V4 setup"

  let(:validity) { Range.new(Time.zone.tomorrow.to_date, 6.months.from_now.to_date, exclude_end: true) }
  let(:records) { model.all }

  describe "#perform" do
    let(:perform_service) { described_class.new(frame: frame, model: model, conflict_keys: conflict_keys).perform }

    context "when the model is Pricings::Pricing" do
      let(:conflict_keys) { %w[itinerary_id cargo_class organization_id group_id tenant_vehicle_id] }
      let(:model) { Pricings::Pricing }
      let!(:pricing) do
        FactoryBot.create(:pricings_pricing,
          organization: organization,
          group: default_group,
          effective_date: validity.first,
          expiration_date: (validity.last - 1.day).end_of_day,
          validity: validity)
      end
      let(:rows) do
        [
          pricing.slice(*conflict_keys).merge("effective_date" => start_date, "expiration_date" => end_date, "row" => 1)
        ]
      end

      context "when the date matches exactly" do
        let(:start_date) { Time.zone.tomorrow.to_date }
        let(:end_date) { 6.months.from_now.to_date }

        before { perform_service }

        it "detects the overlap and soft deletes the existing pricing" do
          expect(records.count).to eq(0)
        end
      end

      context "when contained_by_new" do
        let(:validity) { Range.new(1.month.from_now.to_date, 2.months.from_now.to_date, exclude_end: true) }
        let(:start_date) { Time.zone.tomorrow.to_date }
        let(:end_date) { 3.months.from_now.to_date }

        before { perform_service }

        it "detects the overlap and soft deletes the existing pricing" do
          expect(records.count).to eq(0)
        end
      end

      context "when the date is contained_by_existing" do
        let(:validity) { Range.new(Time.zone.tomorrow.to_date, 4.months.from_now.to_date, exclude_end: true) }
        let(:start_date) { 1.month.from_now.to_date }
        let(:end_date) { 2.months.from_now.to_date }
        let(:expected_validities) do
          [
            Range.new(Time.zone.tomorrow.to_date, start_date, exclude_end: true)
          ]
        end

        before { perform_service }

        it "splits the existing pricing validity around the set dates" do
          expect(records.pluck(:validity)).to match_array(expected_validities)
        end
      end

      context "when the date is extends_past_existing" do
        let(:validity) { Range.new(Time.zone.tomorrow.to_date, 2.months.from_now.to_date, exclude_end: true) }
        let(:start_date) { 1.month.from_now.to_date }
        let(:end_date) { 3.months.from_now.to_date }
        let(:expected_validities) do
          [
            Range.new(Time.zone.tomorrow.to_date, 1.month.from_now.to_date, exclude_end: true)
          ]
        end

        before { perform_service }

        it "detects the overlap and updates the existing pricing validity" do
          expect(records.pluck(:validity)).to match_array(expected_validities)
        end
      end

      context "when straddling two existing pricing sets" do
        let(:validity) { Range.new(Time.zone.tomorrow.to_date, 2.months.from_now.to_date, exclude_end: true) }
        let(:start_date) { 1.month.from_now.to_date }
        let(:end_date) { 3.months.from_now.to_date }
        let(:expected_validities) do
          [
            Range.new(Time.zone.tomorrow.to_date, 1.month.from_now.to_date, exclude_end: true)
          ]
        end

        before do
          pricing.dup.tap do |new_pricing|
            future_validity = Range.new(2.months.from_now.to_date, 6.months.from_now.to_date, exclude_end: true)
            new_pricing.update(
              effective_date: future_validity.first,
              expiration_date: (future_validity.last - 1.day).end_of_day,
              validity: future_validity
            )
          end
          perform_service
        end

        it "detects the overlap and updates the existing pricing validity" do
          expect(records.pluck(:validity)).to match_array(expected_validities)
        end
      end
    end

    context "when the model is Trucking::Trucking" do
      let(:conflict_keys) { %w[hub_id cargo_class organization_id group_id tenant_vehicle_id carriage country_id] }
      let(:model) { Trucking::Trucking }
      let!(:trucking) do
        FactoryBot.create(:trucking_trucking,
          organization: organization,
          group: default_group,
          validity: validity)
      end
      let(:rows) do
        [
          trucking.slice(*(conflict_keys - ["country_id"])).merge("effective_date" => start_date, "expiration_date" => end_date, "row" => 1, "country_id" => trucking.location.country_id)
        ]
      end

      context "when the date matches exactly" do
        let(:start_date) { Time.zone.tomorrow.to_date }
        let(:end_date) { 6.months.from_now.to_date }

        before { perform_service }

        it "detects the overlap and soft deletes the existing pricing" do
          expect(records.count).to eq(0)
        end
      end
    end

    context "when the model is Legacy::LocalCharge" do
      let(:conflict_keys) { %w[hub_id counterpart_hub_id tenant_vehicle_id load_type mode_of_transport group_id direction organization_id] }
      let(:model) { Legacy::LocalCharge }
      let!(:trucking) do
        FactoryBot.create(:legacy_local_charge,
          organization: organization,
          effective_date: validity.first,
          expiration_date: (validity.last - 1.day).end_of_day,
          group: default_group,
          validity: validity)
      end
      let(:rows) do
        [
          trucking.slice(*conflict_keys).merge("effective_date" => start_date, "expiration_date" => end_date, "row" => 1)
        ]
      end

      context "when the date matches exactly" do
        let(:start_date) { Time.zone.tomorrow.to_date }
        let(:end_date) { 6.months.from_now.to_date }

        before { perform_service }

        it "detects the overlap and soft deletes the existing pricing" do
          expect(records.count).to eq(0)
        end
      end
    end
  end
end
