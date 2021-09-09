# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Overlaps::ExtendsBeforeExisting do
  include_context "with overlaps setup"

  let(:validity) { Range.new(Date.parse("2021/02/01"), Date.parse("2021/04/01"), exclude_end: true) }
  let(:start_date) { Date.parse("2021/01/01") }
  let(:end_date) { Date.parse("2021/02/28") }

  describe "#perform" do
    Timecop.freeze(DateTime.parse("2020/12/31")) do
      before { described_class.new(model: model, arguments: arguments).perform }

      shared_examples_for "ExtendsBeforeExisting" do
        let(:target_validity) { Range.new(Date.parse("2021/03/01"), Date.parse("2021/04/01"), exclude_end: true) }

        it "detects the overlap and deletes the old models" do
          expect(target.reload.validity).to eq(target_validity)
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

        it_behaves_like "ExtendsBeforeExisting"
      end

      context "when the model is Pricings::Pricing" do
        let(:model) { Pricings::Pricing }
        let!(:target) do
          FactoryBot.create(:pricings_pricing,
            organization: organization,
            group: default_group,
            tenant_vehicle: tenant_vehicle,
            effective_date: validity.first,
            expiration_date: (validity.last - 1.day).end_of_day,
            validity: validity)
        end

        let(:arguments) do
          target.slice(
            :itinerary_id, :cargo_class, :organization_id, :group_id, :tenant_vehicle_id
          ).merge(effective_date: start_date, expiration_date: end_date)
            .symbolize_keys
        end

        it_behaves_like "ExtendsBeforeExisting"
      end
    end
  end
end
