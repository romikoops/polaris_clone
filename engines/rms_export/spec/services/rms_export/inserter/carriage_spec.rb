# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::RmsExport::Inserter::Carriage do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:hub) { FactoryBot.create(:hamburg_hub, organization: organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'TEST', organization: organization) }
  let!(:trucking_locations) do
    [
      FactoryBot.create(:trucking_location, zipcode: '12344'),
      FactoryBot.create(:trucking_location, zipcode: '12345'),
      FactoryBot.create(:trucking_location, zipcode: '12346')
    ]
  end

  let!(:truckings) do
    trucking_locations.map do |tl|
      FactoryBot.create(:trucking_trucking, location: tl, organization: organization, hub: hub, tenant_vehicle: tenant_vehicle) 
    end
  end
  let!(:routes) do
    [
      FactoryBot.create(:freight_route, origin_location: :hamburg, destination_location: :shanghai, all_mots: true)
    ]
  end

  describe '.perform' do
    it 'creates the carriage' do
      RmsSync::Carriage.new(organization_id: organization.id, sheet_type: :carriage).perform
      data = RmsExport::Parser::Carriage.new(organization_id: organization.id).perform
      RmsExport::Inserter::Carriage.new(organization_id: organization.id, data: data).perform
      expect(TenantRouting::Connection.count).to eq(1)
      expect(Routing::LineService.count).to eq(1)
      expect(Routing::Route.where(mode_of_transport: :carriage).count).to eq(6)
      expect(Routing::RouteLineService.count).to eq(6)
    end

  end
end