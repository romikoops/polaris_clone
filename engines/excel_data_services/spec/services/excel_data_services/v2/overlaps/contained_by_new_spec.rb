# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Overlaps::ContainedByNew do
  include_context "with overlaps setup"

  let(:validity) { Range.new(Date.parse("2021/02/01"), Date.parse("2021/03/01"), exclude_end: true) }
  let(:start_date) { Date.parse("2021/01/01") }
  let(:end_date) { Date.parse("2021/03/31") }

  describe "#perform" do
    before { described_class.new(model: model, arguments: arguments).perform }

    Timecop.freeze(DateTime.parse("2020/12/31")) do
      shared_examples_for "ContainedByNew Conflict (Fully Contained)" do
        it "detects the overlap and deletes the old models" do
          expect(target.reload.deleted_at).to be_present
        end
      end

      shared_examples_for "ContainedByNew Conflict (Exact Match)" do
        let(:start_date) { Date.parse("2021/02/01") }
        let(:end_date) { Date.parse("2021/02/28") }

        it "detects the overlap and deletes the old models" do
          expect(target.reload.deleted_at).to be_present
        end
      end

      context "when the model is Trucking::Trucking" do
        include_context "with standard trucking setup"
        let(:model) { Trucking::Trucking }
        let!(:target) do
          FactoryBot.create(:trucking_trucking,
            organization: organization,
            hub: hub,
            group: default_group,
            tenant_vehicle: tenant_vehicle,
            validity: validity)
        end

        let(:arguments) do
          target.slice(
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

        it_behaves_like "ContainedByNew Conflict (Fully Contained)"
        it_behaves_like "ContainedByNew Conflict (Exact Match)"
      end

      context "when the model is Pricings::Pricing" do
        let(:model) { Pricings::Pricing }
        let!(:target) do
          FactoryBot.create(:pricings_pricing,
            organization: organization,
            group: default_group,
            tenant_vehicle: tenant_vehicle,
            effective_date: DateTime.parse("2021/02/01"),
            expiration_date: DateTime.parse("2021/02/28").end_of_day,
            validity: validity)
        end

        let(:arguments) do
          target.slice(
            :itinerary_id, :cargo_class, :organization_id, :group_id, :tenant_vehicle_id
          ).merge(effective_date: start_date, expiration_date: end_date)
            .symbolize_keys
        end

        it_behaves_like "ContainedByNew Conflict (Fully Contained)"
        it_behaves_like "ContainedByNew Conflict (Exact Match)"
      end
    end
  end
end
