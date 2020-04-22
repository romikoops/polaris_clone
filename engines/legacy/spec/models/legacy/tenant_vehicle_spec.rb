# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe TenantVehicle, type: :model do
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: 'TEST') }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier) }

    describe '.with_carrier' do
      it 'returns the tenant vehicle with carrier info' do
        target = tenant_vehicle.with_carrier
        aggregate_failures do
          expect(target.dig('carrier', 'name')).to eq(carrier.name)
          expect(target.dig('carrier', 'id')).to eq(carrier.id)
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: tenant_vehicles
#
#  id                :bigint           not null, primary key
#  is_default        :boolean
#  mode_of_transport :string
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  carrier_id        :integer
#  sandbox_id        :uuid
#  tenant_id         :integer
#  vehicle_id        :integer
#
# Indexes
#
#  index_tenant_vehicles_on_sandbox_id  (sandbox_id)
#  index_tenant_vehicles_on_tenant_id   (tenant_id)
#
