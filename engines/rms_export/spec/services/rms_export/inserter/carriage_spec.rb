# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::RmsExport::Inserter::Carriage do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:tenants_tenant) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:hub) { FactoryBot.create(:hamburg_hub, tenant: tenant) }
  let(:courier) { FactoryBot.create(:trucking_courier, name: 'TEST', tenant: tenant) }
  let!(:trucking_locations) do
    [
      FactoryBot.create(:trucking_location, zipcode: '12344'),
      FactoryBot.create(:trucking_location, zipcode: '12345'),
      FactoryBot.create(:trucking_location, zipcode: '12346')
    ]
  end

  let!(:truckings) do
    trucking_locations.map do |tl|
      FactoryBot.create(:trucking_trucking, location: tl, tenant: tenant, hub: hub, courier: courier) 
    end
  end
  let!(:routes) do
    [
      FactoryBot.create(:freight_route, origin_location: :hamburg, destination_location: :shanghai, all_mots: true)
    ]
  end

  describe '.perform' do
    it 'creates the carriage' do
      RmsSync::Carriage.new(tenant_id: tenants_tenant.id, sheet_type: :carriage).perform
      data = RmsExport::Parser::Carriage.new(tenant_id: tenants_tenant.id).perform
      RmsExport::Inserter::Carriage.new(tenant_id: tenants_tenant.id, data: data).perform
      expect(TenantRouting::Connection.count).to eq(1)
      expect(Routing::LineService.count).to eq(1)
      expect(Routing::Route.where(mode_of_transport: :carriage).count).to eq(6)
      expect(Routing::RouteLineService.count).to eq(6)
    end

  end
end