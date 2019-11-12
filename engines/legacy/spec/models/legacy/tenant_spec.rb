# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Tenant, type: :model do
    let!(:tenant) { FactoryBot.create(:legacy_tenant, subdomain: 'demo') }

    describe '.subdomain' do
      it 'returns the subdomain of the tenant' do
        expect(tenant.subdomain).to eq('demo')
      end
    end

    describe '.__subdomain' do
      it 'returns the subdomain of the tenant' do
        expect(tenant.__subdomain).to eq('demo')
      end
    end
  end
end
