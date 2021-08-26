# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Overlaps::ExtendsBeforeExisting do
  include_context "with standard trucking setup"

  let!(:trucking) do
    FactoryBot.create(:trucking_trucking,
      organization: organization,
      hub: hub,
      group: default_group,
      tenant_vehicle: tenant_vehicle,
      validity: validity)
  end
  let(:validity) { Range.new(2.months.from_now, 6.months.from_now.to_date, exclude_end: true) }
  let(:default_group) { FactoryBot.create(:groups_group, organization: organization, name: "default") }
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
  end
  let(:post_trucking) { Range.new(5.months.from_now.to_date, 6.months.from_now.to_date, exclude_end: true) }

  before { described_class.new(model: Trucking::Trucking, arguments: arguments).perform }

  describe "#perform" do
    context "when the new extends before the old" do
      let(:start_date) { Time.zone.today }
      let(:end_date) { 5.months.from_now.to_date }

      it "detects the overlap and adjusts the old validity" do
        expect(trucking.reload.validity).to eq(post_trucking)
      end
    end
  end
end
