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

    context 'with quotation tool' do
      let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }

      before do
        FactoryBot.create(:tenants_scope, content: { open_quotation_tool: true }, target: tenants_tenant)
        target_class.new.create_internal_users(tenant)
      end

      it 'tenant should have four users' do
        expect(tenant.users.size).to eq(4)
      end
    end
  end

  describe '#seed_demo_site' do
    before do
      FactoryBot.create(:tenant, subdomain: 'demo')
      allow(Address).to receive(:create_and_geocode).and_return(*FactoryBot.create_list(:address, 6))
    end

    shared_examples_for 'Multi Tenant tool' do |klass_names|
      klass_names.each do |klass|
        it "increases #{klass.downcase.pluralize} count" do
          expect { target_class.new.seed_demo_site('demo', 'com') }.to(change { klass.constantize.count })
        end
      end
    end
    it_behaves_like 'Multi Tenant tool', %w[User Profiles::Profile Contact]
  end
end
