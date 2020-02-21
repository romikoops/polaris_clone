# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe UserSerializer do
    let(:tenant) { FactoryBot.create(:legacy_tenant) }
    let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, email: 'secure@itsmycargo.com') }
    let(:serialized_user) { described_class.new(user).serializable_hash }

    it 'returns the correct email for the user object' do
      expect(serialized_user[:email]).to eq('secure@itsmycargo.com')
    end

    it 'returns the right tenant_id for the user object' do
      expect(serialized_user[:tenant_id]).to eq(tenant.id)
    end
  end
end
