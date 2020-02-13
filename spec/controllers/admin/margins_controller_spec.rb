# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::MarginsController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', tenant: tenant) }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'faster', tenant: tenant) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:itinerary_1) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:company) do
    company = create(:tenants_company, name: 'Test', tenant: tenants_tenant)
    tenants_user.update(company_id: company.id)
    company
  end

  let(:group) do
    group = create(:tenants_group, tenant: tenants_tenant)
    create(:tenants_membership, member: tenants_user, group: group)
    group
  end
  let(:json_response) { JSON.parse(response.body) }
  let(:lcl_pricing) { FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_tenant).and_return(tenant)
    allow(controller).to receive(:require_login_and_role_is_admin).and_return(true)

    FactoryBot.create(:tenants_scope, content: {}, target: tenants_tenant)
    %w[ocean air rail truck trucking local_charge].map do |mot|
      [
        FactoryBot.create(:freight_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_on_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_pre_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:import_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:export_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
      ]
    end
  end

  describe 'POST #test' do
    it 'returns http success for a User target' do
      user_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: tenants_user)
      args = {
        selectedOriginHub: itinerary_1.hubs.first.id,
        selectedDestinationHub: itinerary_1.hubs.last.id,
        selectedCargoClass: 'lcl',
        targetId: user.id,
        targetType: 'user',
        tenant_id: tenant.id
      }

      post :test, params: args

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        results = json.dig('data', 'results')
        expect(results.length).to eq(1)
        expect(results.first).to include(
          'freight' => {
            'fees' => {
              'bas' => {
                'original' => { 'rate' => '25.0', 'base' => '1.0', 'rate_basis' => 'PER_WM', 'currency' => 'EUR', 'hw_threshold' => nil, 'hw_rate_basis' => nil, 'min' => '1.0', 'range' => [] },
                'margins' => [
                  { 'margin_id' => user_margin.id,
                    'margin_value' => '0.1',
                    'operator' => '%',
                    'data' => { 'rate' => '27.5', 'base' => '1.0', 'rate_basis' => 'PER_WM', 'currency' => 'EUR', 'hw_threshold' => nil, 'hw_rate_basis' => nil, 'min' => '1.1', 'range' => [] },
                    'target_name' => nil,
                    'target_id' => tenants_user.id,
                    'target_type' => 'Tenants::User',
                    'url_id' => user.id }
                ],
                'flatMargins' => [],
                'final' => { 'rate' => '27.5', 'base' => '1.0', 'rate_basis' => 'PER_WM', 'currency' => 'EUR', 'hw_threshold' => nil, 'hw_rate_basis' => nil, 'min' => '1.1', 'range' => [] },
                'rate_origin' => nil
              }
            },
            'service_level' => tenant_vehicle_1.name
          }
        )
      end
    end

    it 'returns http success for a Company target' do
      company_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: company)
      args = {
        selectedOriginHub: itinerary_1.hubs.first.id,
        selectedDestinationHub: itinerary_1.hubs.last.id,
        selectedCargoClass: 'lcl',
        targetId: company.id,
        targetType: 'company',
        tenant_id: tenant.id
      }

      post :test, params: args

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        results = json.dig('data', 'results')
        expect(results.length).to eq(1)
        expect(results.first).to include(
          'freight' => {
            'fees' => {
              'bas' => {
                'original' => { 'rate' => '25.0', 'base' => '1.0', 'rate_basis' => 'PER_WM', 'currency' => 'EUR', 'hw_threshold' => nil, 'hw_rate_basis' => nil, 'min' => '1.0', 'range' => [] },
                'margins' => [
                  { 'margin_id' => company_margin.id,
                    'margin_value' => '0.1',
                    'operator' => '%',
                    'data' => { 'rate' => '27.5', 'base' => '1.0', 'rate_basis' => 'PER_WM', 'currency' => 'EUR', 'hw_threshold' => nil, 'hw_rate_basis' => nil, 'min' => '1.1', 'range' => [] },
                    'target_name' => company.name,
                    'target_id' => company.id,
                    'target_type' => 'Tenants::Company',
                    'url_id' => company.id }
                ],
                'flatMargins' => [],
                'final' => { 'rate' => '27.5', 'base' => '1.0', 'rate_basis' => 'PER_WM', 'currency' => 'EUR', 'hw_threshold' => nil, 'hw_rate_basis' => nil, 'min' => '1.1', 'range' => [] },
                'rate_origin' => nil
              }
            },
            'service_level' => tenant_vehicle_1.name
          }
        )
      end
    end

    it 'returns http success for a Group target' do
      group_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: group)
      args = {
        selectedOriginHub: itinerary_1.hubs.first.id,
        selectedDestinationHub: itinerary_1.hubs.last.id,
        selectedCargoClass: 'lcl',
        targetId: group.id,
        targetType: 'group',
        tenant_id: tenant.id
      }

      post :test, params: args

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        results = json.dig('data', 'results')
        expect(results.length).to eq(1)
        expect(results.first).to include(
          'freight' => {
            'fees' => {
              'bas' => {
                'original' => { 'rate' => '25.0', 'base' => '1.0', 'rate_basis' => 'PER_WM', 'currency' => 'EUR', 'hw_threshold' => nil, 'hw_rate_basis' => nil, 'min' => '1.0', 'range' => [] },
                'margins' => [
                  { 'margin_id' => group_margin.id,
                    'margin_value' => '0.1',
                    'operator' => '%',
                    'data' => { 'rate' => '27.5', 'base' => '1.0', 'rate_basis' => 'PER_WM', 'currency' => 'EUR', 'hw_threshold' => nil, 'hw_rate_basis' => nil, 'min' => '1.1', 'range' => [] },
                    'target_name' => group.name,
                    'target_id' => group.id,
                    'target_type' => 'Tenants::Group',
                    'url_id' => group.id }
                ],
                'flatMargins' => [],
                'final' => { 'rate' => '27.5', 'base' => '1.0', 'rate_basis' => 'PER_WM', 'currency' => 'EUR', 'hw_threshold' => nil, 'hw_rate_basis' => nil, 'min' => '1.1', 'range' => [] },
                'rate_origin' => nil
              }
            },
            'service_level' => tenant_vehicle_1.name
          }
        )
      end
    end
  end

  describe 'POST #upload' do
    before do
      allow(Legacy::File).to receive(:create!)
    end

    it 'returns error with messages when an error is raised' do
      post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1 }
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response['data']).not_to be_empty
      end
    end
  end
end
