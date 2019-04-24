# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenants::HierarchyService do
  describe '#perform' do
    context 'user is nil' do
      let(:user) { nil }

      it 'returns an empty array' do
        expect(described_class.new(user: user).fetch).to eq([])
      end
    end

    context 'user is not nil' do
      let(:tenant) { FactoryBot.create(:tenants_tenant) }
      let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }

      it 'returns the correct hierarchy' do
        expect(described_class.new(user: user).fetch).to eq([tenant, user])
      end
    end
  end
end
