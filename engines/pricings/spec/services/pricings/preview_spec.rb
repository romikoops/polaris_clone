# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pricings::Preview do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', tenant: tenant) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:itinerary_1) { FactoryBot.create(:default_itinerary, tenant: tenant) }

  describe '.perform' do
    it 'retruns the examples' do
      lcl_pricing = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1)
      user_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: tenants_user)
      results = described_class.new(target: tenants_user, itinerary_id: itinerary_1.id).perform

      expect(results.length).to eq(1)
      expect(results.dig(0, 0, 'id')).to eq(lcl_pricing.id)
      expect(results.dig(0, 0, 'manipulation_steps', 0, 'margin', 'id')).to eq(user_margin.id)
      expect(results.dig(0, 0, 'manipulation_steps', 0, 'fees', 'bas', 'rate')).to eq(27.5)
    end
    it 'retruns the examples for a company' do
      company_1 = FactoryBot.create(:tenants_company, tenant: tenants_tenant)
      tenants_user.company = company_1
      tenants_user.save
      lcl_pricing = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1)
      company_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: company_1)
      results = described_class.new(target: company_1, itinerary_id: itinerary_1.id).perform

      expect(results.length).to eq(1)
      expect(results.dig(0, 0, 'id')).to eq(lcl_pricing.id)
      expect(results.dig(0, 0, 'manipulation_steps', 0, 'margin', 'id')).to eq(company_margin.id)
      expect(results.dig(0, 0, 'manipulation_steps', 0, 'fees', 'bas', 'rate')).to eq(27.5)
    end
    it 'retruns the examples for a company through the user' do
      company_1 = FactoryBot.create(:tenants_company, tenant: tenants_tenant)
      tenants_user.company = company_1
      tenants_user.save
      lcl_pricing = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1)
      company_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: company_1)
      results = described_class.new(target: tenants_user, itinerary_id: itinerary_1.id).perform

      expect(results.length).to eq(1)
      expect(results.dig(0, 0, 'id')).to eq(lcl_pricing.id)
      expect(results.dig(0, 0, 'manipulation_steps', 0, 'margin', 'id')).to eq(company_margin.id)
      expect(results.dig(0, 0, 'manipulation_steps', 0, 'fees', 'bas', 'rate')).to eq(27.5)
    end
    it 'retruns the examples with the steps in correct order' do
      lcl_pricing = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1)
      user_margin_1 = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: tenants_user, application_order: 0)
      user_margin_2 = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: tenants_user, application_order: 2)
      user_margin_3 = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: tenants_user, application_order: 3)
      results = described_class.new(target: tenants_user, itinerary_id: itinerary_1.id).perform

      expect(results.length).to eq(1)
      expect(results.dig(0, 0, 'id')).to eq(lcl_pricing.id)
      expect(results.dig(0, 0, 'manipulation_steps', 0, 'margin', 'id')).to eq(user_margin_1.id)
      expect(results.dig(0, 0, 'manipulation_steps', 0, 'fees', 'bas', 'rate')).to eq(27.5)
      expect(results.dig(0, 0, 'manipulation_steps', 1, 'margin', 'id')).to eq(user_margin_2.id)
      expect(results.dig(0, 0, 'manipulation_steps', 1, 'fees', 'bas', 'rate')).to eq(30.25)
      expect(results.dig(0, 0, 'manipulation_steps', 2, 'margin', 'id')).to eq(user_margin_3.id)
      expect(results.dig(0, 0, 'manipulation_steps', 2, 'fees', 'bas', 'rate')).to eq(33.275)
    end
    it 'retruns the examples with the steps in correct order with different origins' do
      lcl_pricing = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1)
      group_1 = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      FactoryBot.create(:tenants_membership, member: tenants_user, group: group_1)
      user_margin_1 = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: tenants_user, application_order: 0)
      group_margin_1 = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: group_1, application_order: 0, value: 0.05)
      group_margin_2 = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: group_1, application_order: 1, value: 0.15)
      results = described_class.new(target: tenants_user, itinerary_id: itinerary_1.id).perform

      expect(results.length).to eq(1)
      expect(results.dig(0, 0, 'id')).to eq(lcl_pricing.id)
      expect(results.dig(0, 0, 'manipulation_steps', 0, 'margin', 'id')).to eq(user_margin_1.id)
      expect(results.dig(0, 0, 'manipulation_steps', 0, 'fees', 'bas', 'rate')).to eq(27.5)
      expect(results.dig(0, 0, 'manipulation_steps', 1, 'margin', 'id')).to eq(group_margin_1.id)
      expect(results.dig(0, 0, 'manipulation_steps', 1, 'fees', 'bas', 'rate')).to eq(28.875)
      expect(results.dig(0, 0, 'manipulation_steps', 2, 'margin', 'id')).to eq(group_margin_2.id)
      expect(results.dig(0, 0, 'manipulation_steps', 2, 'fees', 'bas', 'rate')).to eq(33.20625)
    end
    it 'retruns the examples with the steps in correct order with different origins and from group' do
      lcl_pricing = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1)
      fcl_20_pricing = FactoryBot.create(:fcl_20_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1)
      group_1 = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      FactoryBot.create(:tenants_membership, member: tenants_user, group: group_1)
      user_margin_1 = FactoryBot.create(:freight_margin,
                                        pricing: lcl_pricing,
                                        tenant: tenants_tenant,
                                        applicable: group_1,
                                        application_order: 0)
      user_margin_2 = FactoryBot.create(:freight_margin,
                                        pricing: fcl_20_pricing,
                                        tenant: tenants_tenant,
                                        applicable: group_1,
                                        application_order: 0)
      group_margin_1 = FactoryBot.create(:freight_margin,
                                         pricing: lcl_pricing,
                                         tenant: tenants_tenant,
                                         applicable: group_1,
                                         application_order: 0,
                                         value: 0.05)
      group_margin_2 = FactoryBot.create(:freight_margin,
                                         pricing: lcl_pricing,
                                         tenant: tenants_tenant,
                                         applicable: group_1,
                                         application_order: 1,
                                         value: 0.15)
      results = described_class.new(target: group_1, itinerary_id: itinerary_1.id).perform
      lcl_index = results.index {|r| r.first['id'] == lcl_pricing.id}
      fcl_index = results.index {|r| r.first['id'] === fcl_20_pricing.id}
      expect(results.length).to eq(2)
      expect(results.dig(lcl_index, 0, 'id')).to eq(lcl_pricing.id)
      expect(results.dig(lcl_index, 0, 'manipulation_steps', 0, 'margin', 'id')).to eq(user_margin_1.id)
      expect(results.dig(lcl_index, 0, 'manipulation_steps', 0, 'fees', 'bas', 'rate')).to eq(27.5)
      expect(results.dig(lcl_index, 0, 'manipulation_steps', 1, 'margin', 'id')).to eq(group_margin_1.id)
      expect(results.dig(lcl_index, 0, 'manipulation_steps', 1, 'fees', 'bas', 'rate')).to eq(28.875)
      expect(results.dig(lcl_index, 0, 'manipulation_steps', 2, 'margin', 'id')).to eq(group_margin_2.id)
      expect(results.dig(lcl_index, 0, 'manipulation_steps', 2, 'fees', 'bas', 'rate')).to eq(33.20625)
      expect(results.dig(fcl_index, 0, 'id')).to eq(fcl_20_pricing.id)
      expect(results.dig(fcl_index, 0, 'manipulation_steps', 0, 'margin', 'id')).to eq(user_margin_2.id)
    end
  end
end
