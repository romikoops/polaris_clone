# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::Hubs do
  describe '.perform' do
    let(:tenant) { create(:tenant) }
    let(:data) do
      [{ original:
         { status: 'active',
           type: 'ocean',
           name: 'Abu Dhabi',
           locode: 'AEAUH',
           latitude: 24.806936,
           longitude: 54.644405,
           country: 'United Arab Emirates',
           full_address: 'Khalifa Port - Abu Dhabi - United Arab Emirates',
           photo: nil,
           free_out: false,
           import_charges: true,
           export_charges: false,
           pre_carriage: false,
           on_carriage: false,
           alternative_names: nil,
           row_nr: 2 },
         address:
         { name: 'Abu Dhabi',
           latitude: 24.806936,
           longitude: 54.644405,
           country: { name: 'United Arab Emirates' },
           city: 'Abu Dhabi',
           geocoded_address: 'Khalifa Port - Abu Dhabi - United Arab Emirates',
           sandbox: nil },
         nexus: { name: 'Abu Dhabi', latitude: 24.806936, longitude: 54.644405, photo: nil, locode: 'AEAUH', country: { name: 'United Arab Emirates' }, tenant_id: tenant.id, sandbox: nil },
         mandatory_charge: { pre_carriage: false, on_carriage: false, import_charges: false, export_charges: true },
         hub: { tenant_id: tenant.id, hub_type: 'ocean', latitude: 24.806936, longitude: 54.644405, name: 'Abu Dhabi Port', photo: nil, sandbox: nil, hub_code: 'AEAUH' } },
       { original:
         { status: 'active',
           type: 'ocean',
           name: 'Adelaide',
           locode: 'AUADL',
           latitude: -34.9284989,
           longitude: 138.6007456,
           country: 'Australia',
           full_address: '202 Victoria Square, Adelaide SA 5000, Australia',
           photo: nil,
           free_out: false,
           import_charges: true,
           export_charges: false,
           pre_carriage: false,
           on_carriage: false,
           alternative_names: nil,
           row_nr: 3 },
         address:
         { name: 'Adelaide',
           latitude: -34.9284989,
           longitude: 138.6007456,
           country: { name: 'Australia' },
           city: 'Adelaide',
           geocoded_address: '202 Victoria Square, Adelaide SA 5000, Australia',
           sandbox: nil },
         nexus: { name: 'Adelaide', latitude: -34.9284989, longitude: 138.6007456, photo: nil, locode: 'AUADL', country: { name: 'Australia' }, tenant_id: tenant.id, sandbox: nil },
         mandatory_charge: { pre_carriage: false, on_carriage: false, import_charges: true, export_charges: false },
         hub: { tenant_id: tenant.id, hub_type: 'ocean', latitude: -34.9284989, longitude: 138.6007456, name: 'Adelaide Port', photo: nil, sandbox: nil, hub_code: 'AUADL' } }]
    end

    let!(:countries) do
      [
        create(:country, name: 'Australia', code: 'AU'),
        create(:country, name: 'United Arab Emirates', code: 'AE')
      ]
    end
    let!(:mandatory_charges) do
      [
        create(:mandatory_charge, pre_carriage: false, on_carriage: false, import_charges: true, export_charges: false),
        create(:mandatory_charge, pre_carriage: false, on_carriage: false, import_charges: false, export_charges: true)
      ]
    end

    it 'creates the correct number of hubs' do
      stats = described_class.insert(tenant: tenant, data: data, options: {})
      hubs = Hub.where(tenant_id: tenant.id)
      addresses = Address.all
      expect(stats.dig(:"legacy/hubs", :number_created)).to be(2)
      expect(stats.dig(:"legacy/nexuses", :number_created)).to be(2)
      expect(stats.dig(:"legacy/addresses", :number_created)).to be(2)
      expect(hubs.count).to be(2)
      expect(hubs.pluck(:mandatory_charge_id)).to match_array(mandatory_charges.pluck(:id))
      expect(Nexus.where(tenant_id: tenant.id).count).to be(2)
      expect(addresses.count).to be(2)
      expect(addresses.map(&:country)).to match_array(countries)
    end

    context 'with existing hubs' do
      before do
        create(:hub,
          name: 'ADL Port',
          hub_code: 'AUADL',
          tenant: tenant,
          address: create(:address, country: countries.first),
          nexus: create(:nexus,
                        name: 'ADL',
                        tenant: tenant,
                        locode: 'AUADL',
                        country: countries.first))
      end

      let(:stats) { described_class.insert(tenant: tenant, data: data, options: {}) }
      let(:hubs) { Hub.where(tenant_id: tenant.id) }
      let(:addresses) { Address.all }

      it 'creates the correct number of hubs and updates the rest' do
        aggregate_failures do
          expect(stats.dig(:"legacy/hubs", :number_created)).to be(1)
          expect(stats.dig(:"legacy/nexuses", :number_created)).to be(1)
          expect(stats.dig(:"legacy/addresses", :number_created)).to be(2)
          expect(hubs.count).to be(2)
          expect(hubs.pluck(:mandatory_charge_id)).to match_array(mandatory_charges.pluck(:id))
          expect(Nexus.where(tenant_id: tenant.id).count).to be(2)
          expect(addresses.count).to be(3)
          expect(addresses.map(&:country).uniq).to match_array(countries)
        end
      end
    end
  end
end
