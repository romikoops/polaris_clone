# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenants::CreatorService do
  let(:params) {
    {
      name: 'Test',
      slug: 'tester',
      theme_attributes: {
        primary_color: '#000001',
        secondary_color: '#000002',
        bright_primary_color: '#000003',
        bright_secondary_color: '#000004'
      },
      scope: {
        base_pricing: true
      }.to_json.to_s
    }
  }
  let!(:cargo_item_types) { FactoryBot.create(:legacy_cargo_item_type)}
  describe '#perform' do
    it 'it creates a new tenant and all the required data' do
      tenant = described_class.new(params: params).perform
      legacy_tenant = tenant.legacy
      theme = tenant.theme
      scope = tenant.scope
      expect(tenant.slug).to eq('tester')
      expect(legacy_tenant.subdomain).to eq('tester')
      expect(legacy_tenant.name).to eq('Test')
      expect(Legacy::MaxDimensionsBundle.where(tenant: legacy_tenant).count).to eq(4)
      expect(tenant.domains.count).to eq(2)
      expect(tenant.domains.exists?(domain: 'tester.itsmycargo.shop')).to eq(true)
      expect(theme.primary_color).to eq('#000001')
      expect(theme.secondary_color).to eq('#000002')
      expect(theme.bright_primary_color).to eq('#000003')
      expect(theme.bright_secondary_color).to eq('#000004')
      expect(scope.content['base_pricing']).to eq(true)
    end
  end
end
