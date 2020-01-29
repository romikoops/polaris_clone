# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Hub, type: :model do
    describe '.lat_lng_string' do
      let(:hub) { FactoryBot.build(:legacy_hub, :with_lat_lng) }

      it 'returns a string' do
        expect(hub.lat_lng_string).to eql('57.694253,11.854048')
      end
    end

    describe '.distance_to' do
      let(:hub) { FactoryBot.build(:legacy_hub, :with_lat_lng) }
      let(:loc) { FactoryBot.build(:legacy_hub, :with_lat_lng) }

      it 'returns a string' do
        expect(hub.distance_to(loc)).to eql(0.0)
      end
    end

    describe '.lng_lat_array' do
      let(:hub) { FactoryBot.build(:legacy_hub, :with_lat_lng) }

      it 'returns a string' do
        expect(hub.lng_lat_array).to eql([11.854048, 57.694253])
      end
    end
  end
end

# == Schema Information
#
# Table name: hubs
#
#  id                  :bigint           not null, primary key
#  free_out            :boolean          default(FALSE)
#  hub_code            :string
#  hub_status          :string           default("active")
#  hub_type            :string
#  latitude            :float
#  longitude           :float
#  name                :string
#  photo               :string
#  trucking_type       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  address_id          :integer
#  mandatory_charge_id :integer
#  nexus_id            :integer
#  sandbox_id          :uuid
#  tenant_id           :integer
#
# Indexes
#
#  index_hubs_on_sandbox_id  (sandbox_id)
#  index_hubs_on_tenant_id   (tenant_id)
#
