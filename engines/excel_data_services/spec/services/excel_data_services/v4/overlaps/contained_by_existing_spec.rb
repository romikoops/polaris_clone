# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Overlaps::ContainedByExisting do
  include_context "with overlaps setup"

  describe "#perform" do
    Timecop.freeze(DateTime.parse("2020/12/31")) do
      let(:validity) { Range.new(Date.parse("2021/01/01"), Date.parse("2021/04/01"), exclude_end: true) }
      let(:start_date) { Date.parse("2021/02/01") }
      let(:end_date) { Date.parse("2021/02/28") }
      let(:new_validities) do
        [
          Range.new(Date.parse("2021/01/01"), start_date, exclude_end: true),
          Range.new(Date.parse("2021/03/01"), Date.parse("2021/04/01"), exclude_end: true)
        ]
      end

      shared_examples_for "ContainedByExisting Conflict" do
        before { described_class.new(model: model, arguments: arguments).perform }

        it "detects the overlap, splitting the conflict to make a gap for the new validity", :aggregate_failures do
          expect(model.count).to eq(2)
          expect(model.pluck(:validity)).to match_array(new_validities)
        end
      end

      context "when the model is Trucking::Trucking" do
        include_context "with standard trucking setup"
        let(:model) { Trucking::Trucking }
        let!(:trucking) do
          FactoryBot.create(:trucking_trucking,
            organization: organization,
            hub: hub,
            group: default_group,
            tenant_vehicle: tenant_vehicle,
            validity: validity)
        end

        let(:arguments) do
          trucking.slice(
            :hub_id,
            :carriage,
            :load_type,
            :cargo_class,
            :organization_id,
            :truck_type,
            :group_id,
            :tenant_vehicle_id
          ).merge(effective_date: start_date, expiration_date: end_date)
            .symbolize_keys
        end

        it_behaves_like "ContainedByExisting Conflict"
      end

      context "when the model is Pricings::Pricing" do
        let(:model) { Pricings::Pricing }
        let!(:pricing) do
          FactoryBot.create(:pricings_pricing,
            organization: organization,
            group: default_group,
            tenant_vehicle: tenant_vehicle,
            effective_date: DateTime.parse("2021/01/01"),
            expiration_date: DateTime.parse("2021/03/31").end_of_day,
            validity: validity)
        end

        let(:arguments) do
          pricing.slice(
            :itinerary_id, :cargo_class, :organization_id, :group_id, :tenant_vehicle_id
          ).merge(effective_date: start_date, expiration_date: end_date)
            .symbolize_keys
        end

        it_behaves_like "ContainedByExisting Conflict"
      end
    end
  end
end
