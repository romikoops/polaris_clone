# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MultiTenantTools do
  let(:target_class) { Class.new { include MultiTenantTools } }
  let!(:roles) do
    %w[admin manager agent shipper].each do |role|
      create(:role, name: role)
    end
  end

  let(:tenant) { create(:tenant) }

  describe '#create_internal_users' do
    before do
      target_class.new.create_internal_users(tenant)
    end

    it 'tenant should have two users' do
      expect(tenant.users.size).to eq(2)
    end
  end
end
