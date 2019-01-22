# frozen_string_literal: true

require 'rails_helper'

describe Vehicle, type: :model do
  context 'validations' do
    describe '#name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:mode_of_transport).with_message(/taken for mode of transport/) }
    end
  end

  context 'class methods' do
    describe '.create_from_name' do
      let(:tenant) { create(:tenant) }
      let(:vehicle_name) { 'standard' }
      let(:mode_of_transport) { 'air' }

      context 'vehicle not present' do
        it 'creates a new vehicle', pending: 'Broken Tests' do
          expect { described_class.create_from_name(vehicle_name, mode_of_transport, tenant.id) }.to change(described_class, :count).from(0).to(1)
        end

        it 'creates a new tenant vehicle', pending: 'Broken Tests' do
          expect { described_class.create_from_name(vehicle_name, mode_of_transport, tenant.id) }.to change(TenantVehicle, :count).from(0).to(1)
        end

        it 'creates new transport categories', pending: 'Broken Tests' do
          expect { described_class.create_from_name(vehicle_name, mode_of_transport, tenant.id) }.to change(TransportCategory, :count).from(0).to(16)
        end
      end

      context 'vehicle present, no transport categories' do
        let!(:vehicle) { create(:vehicle, name: vehicle_name, mode_of_transport: mode_of_transport) }
        let!(:tenant_vehicle) { create(:tenant_vehicle, name: vehicle_name, mode_of_transport: mode_of_transport, tenant: tenant, vehicle: vehicle) }

        it 'does not create a new vehicle', pending: 'Broken Tests' do
          expect { described_class.create_from_name(vehicle_name, mode_of_transport, tenant.id) }.not_to change(described_class, :count).from(described_class.count)
        end

        it 'does not create a new tenant vehicle', pending: 'Broken Tests' do
          expect { described_class.create_from_name(vehicle_name, mode_of_transport, tenant.id) }.not_to change(TenantVehicle, :count).from(TenantVehicle.count)
        end

        it 'creates new transport categories', pending: 'Broken Tests' do
          expect { described_class.create_from_name(vehicle_name, mode_of_transport, tenant.id) }.to change(TransportCategory, :count).from(TransportCategory.count).to(16)
        end
      end

      context 'transport categories present' do
        let!(:vehicle) { create(:vehicle, name: vehicle_name, mode_of_transport: mode_of_transport) }
        let!(:tenant_vehicle) { create(:tenant_vehicle, name: vehicle_name, mode_of_transport: mode_of_transport, tenant: tenant, vehicle: vehicle) }
        let!(:transport_category) { create(:transport_category, vehicle_id: tenant_vehicle.vehicle_id) }

        it 'does not create new transport categories', pending: 'Outdated spec' do
          expect { described_class.create_from_name(vehicle_name, mode_of_transport, tenant.id) }.not_to change(TransportCategory, :count).from(TransportCategory.count)
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: vehicles
#
#  id                :bigint(8)        not null, primary key
#  name              :string
#  mode_of_transport :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
