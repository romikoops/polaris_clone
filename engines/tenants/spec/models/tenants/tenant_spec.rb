# frozen_string_literal: true

require 'rails_helper'

module Tenants
  RSpec.describe Tenant, type: :model do
    context 'legacy_sync' do
      let(:legacy_tenant) { FactoryBot.build(:legacy_tenant) }

      it '#create_from_legacy' do
        tenant = described_class.create_from_legacy(legacy_tenant)
        expect(tenant).to be_valid
      end

      it '#update_from_legacy' do
        tenant = described_class.create_from_legacy(legacy_tenant)
        tenant.update_from_legacy(legacy_tenant)

        expect(tenant).to be_valid
      end
    end
  end
end
