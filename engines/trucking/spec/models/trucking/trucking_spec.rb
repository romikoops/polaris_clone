# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trucking::Trucking, class: "Trucking::Trucking", type: :model do
  it "is valid with valid attributes" do
    expect(FactoryBot.create(:trucking_trucking)).to be_valid
  end

  context "instance methods" do
    describe ".nexus_id" do
      let(:hub) { FactoryBot.create(:legacy_hub) }
      let!(:trucking) { FactoryBot.create(:trucking_trucking, hub: hub) }

      it "it finds the correct Nexus id for the Trucking Rate" do
        expect(trucking.nexus_id).to eq(hub.nexus_id)
      end
    end

    describe ".hub_id" do
      let(:hub) { FactoryBot.create(:legacy_hub) }
      let!(:trucking) { FactoryBot.create(:trucking_trucking, hub: hub) }

      it "it finds the correct Hub id for the Trucking Rate" do
        expect(trucking.hub_id).to eq(hub.id)
      end
    end
  end
end

# == Schema Information
#
# Table name: trucking_truckings
#
#  id                  :uuid             not null, primary key
#  cargo_class         :string
#  carriage            :string
#  cbm_ratio           :integer
#  fees                :jsonb
#  identifier_modifier :string
#  load_meterage       :jsonb
#  load_type           :string
#  metadata            :jsonb
#  modifier            :string
#  rates               :jsonb
#  truck_type          :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  courier_id          :uuid
#  group_id            :uuid
#  hub_id              :integer
#  location_id         :uuid
#  old_user_id         :integer
#  organization_id     :uuid
#  parent_id           :uuid
#  rate_id             :uuid
#  sandbox_id          :uuid
#  tenant_id           :integer
#  tenant_vehicle_id   :integer
#  user_id             :integer
#
# Indexes
#
#  index_trucking_truckings_on_cargo_class        (cargo_class)
#  index_trucking_truckings_on_carriage           (carriage)
#  index_trucking_truckings_on_group_id           (group_id)
#  index_trucking_truckings_on_hub_id             (hub_id)
#  index_trucking_truckings_on_load_type          (load_type)
#  index_trucking_truckings_on_location_id        (location_id)
#  index_trucking_truckings_on_sandbox_id         (sandbox_id)
#  index_trucking_truckings_on_tenant_id          (tenant_id)
#  index_trucking_truckings_on_tenant_vehicle_id  (tenant_vehicle_id)
#  trucking_foreign_keys                          (rate_id,location_id,hub_id) UNIQUE
#
