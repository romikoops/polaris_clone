# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::RmsSync::Trucking do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:tenants_tenant) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:hub) { FactoryBot.create(:hamburg_hub, tenant: tenant) }
  let(:courier) { FactoryBot.create(:trucking_courier, name: 'TEST', tenant: tenant) }
  let(:zip_trucking_locations) do
    [
      {
        parent_id: SecureRandom.uuid,
        locations: [
          FactoryBot.create(:trucking_location, zipcode: '12344'),
          FactoryBot.create(:trucking_location, zipcode: '12345'),
          FactoryBot.create(:trucking_location, zipcode: '12346')
        ]
      },
      {
        parent_id: SecureRandom.uuid,
        locations: [
          FactoryBot.create(:trucking_location, zipcode: '13344'),
          FactoryBot.create(:trucking_location, zipcode: '14345'),
          FactoryBot.create(:trucking_location, zipcode: '15346')
        ]
      }
    ]
  end
  let(:distance_trucking_locations) do
    [
      {
        parent_id: SecureRandom.uuid,
        locations: [
          FactoryBot.create(:trucking_location, distance: 1),
          FactoryBot.create(:trucking_location, distance: 2),
          FactoryBot.create(:trucking_location, distance: 3)
        ]
      },
      {
        parent_id: SecureRandom.uuid,
        locations: [
          FactoryBot.create(:trucking_location, distance: 14),
          FactoryBot.create(:trucking_location, distance: 25),
          FactoryBot.create(:trucking_location, distance: 36)
        ]
      }
    ]
  end
  let(:city_trucking_locations) do
    [
      {
        parent_id: SecureRandom.uuid,
        locations: [
          FactoryBot.create(:city_location)
        ]
      }
    ]
  end
  let!(:zip_truckings) do
    zip_trucking_locations.flat_map do |tl_obj|
      tl_obj[:locations].map do |tl|
        FactoryBot.create(:trucking_with_fees,
          location: tl,
          tenant: tenant,
          hub: hub,
          courier: courier,
          parent_id: tl_obj[:parent_id]
        )
      end
    end
  end
  let!(:distance_truckings) do
    distance_trucking_locations.flat_map do |tl_obj|
      tl_obj[:locations].map do |tl|
        FactoryBot.create(:trucking_with_return,
          location: tl,
          tenant: tenant,
          cargo_class: 'fcl_20',
          load_type: 'container',
          hub: hub,
          courier: courier,
          parent_id: tl_obj[:parent_id]
        )
      end
    end
  end

  let!(:routes) do
    [
      FactoryBot.create(:hamburg_shanghai_route)
    ]
  end

  describe '.perform' do
    it 'creates the Trucking' do
      RmsSync::Trucking.new(tenant_id: tenants_tenant.id).perform
      books = RmsData::Book.where(tenant_id: tenants_tenant.id, sheet_type: :trucking, target: hub)
      expect(books.length).to eq(2)
      expect(RmsData::Sheet.where(book_id: books.ids).length).to eq(7)
    end

  end
end