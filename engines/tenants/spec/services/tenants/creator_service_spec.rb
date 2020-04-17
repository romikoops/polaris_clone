# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenants::CreatorService do
  let(:params) do
    {
      name: 'Test',
      slug: 'tester',
      theme: {
        primary_color: '#000001',
        secondary_color: '#000002',
        bright_primary_color: '#000003',
        bright_secondary_color: '#000004'
      },
      scope: {
        base_pricing: true
      }.to_json.to_s
    }
  end

  describe '#perform' do
    it 'creates a new tenant and all the required data' do
      tenant = described_class.new(params: params).perform
      legacy_tenant = tenant.legacy
      aggregate_failures do
        expect(tenant.slug).to eq('tester')
        expect(legacy_tenant.name).to eq('Test')
        expect(Legacy::MaxDimensionsBundle.where(tenant: legacy_tenant).count).to eq(4)
        expect(tenant.scope.content['base_pricing']).to eq(true)
      end
    end

    it 'creates the tenant domains' do
      tenant = described_class.new(params: params).perform
      legacy_tenant = tenant.legacy

      aggregate_failures do
        expect(legacy_tenant.subdomain).to eq('tester')
        expect(tenant.domains.count).to eq(1)
        expect(tenant.domains.exists?(domain: 'tester.itsmycargo.shop')).to eq(true)
      end
    end

    it 'creates a theme' do
      tenant = described_class.new(params: params).perform
      theme = tenant.theme
      aggregate_failures do
        expect(theme.primary_color).to eq('#000001')
        expect(theme.secondary_color).to eq('#000002')
        expect(theme.bright_primary_color).to eq('#000003')
        expect(theme.bright_secondary_color).to eq('#000004')
      end
    end
  end
end
