# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::PricingsController, type: :controller do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:json_response) { JSON.parse(response.body) }
  let(:itinerary) do
    FactoryBot.create(:itinerary, tenant_id: tenant.id)
  end

  before do
    allow(controller).to receive(:require_authentication!).and_return(true)
    allow(controller).to receive(:require_non_guest_authentication!).and_return(true)
    allow(controller).to receive(:require_login_and_role_is_admin).and_return(true)
    allow(controller).to receive(:current_tenant).at_least(:once).and_return(tenant)
    allow(controller).to receive(:current_user).at_least(:once).and_return(user)
  end

  describe 'GET #route' do
    before do
      allow(controller).to receive(:current_scope).at_least(:once).and_return('base_pricing' => true)
    end

    let!(:pricings) do
      [
        FactoryBot.create(:pricings_pricing, tenant_id: tenant.id, itinerary_id: itinerary.id),
        FactoryBot.create(:pricings_pricing, tenant_id: tenant.id,
                                             itinerary_id: itinerary.id,
                                             effective_date: DateTime.new(2019, 1, 1),
                                             expiration_date: DateTime.new(2019, 1, 31))
      ]
    end
    let(:expected_response) do
      pricings_table_jsons = [
        { 'id' => pricings.first.id,
          'effective_date' => pricings.first.effective_date,
          'expiration_date' => pricings.first.expiration_date,
          'group_id' => nil,
          'internal' => false,
          'itinerary_id' => itinerary.id,
          'tenant_id' => tenant.id,
          'tenant_vehicle_id' => pricings.first.tenant_vehicle_id,
          'wm_rate' => '0.0',
          'data' => {},
          'load_type' => 'cargo_item',
          'cargo_class' => 'lcl',
          'carrier' => nil,
          'service_level' => 'standard',
          'itinerary_name' => 'Gothenburg - Shanghai',
          'mode_of_transport' => 'ocean' }
      ]

      stops = itinerary.stops
      first_stop = stops.first
      second_stop = stops.second
      stops_table_jsons = [
        { 'id' => first_stop.id,
          'created_at' => first_stop.created_at,
          'hub_id' => first_stop.hub_id,
          'index' => 0,
          'itinerary_id' => itinerary.id,
          'sandbox_id' => nil,
          'updated_at' => first_stop.updated_at,
          'hub' => { 'id' => first_stop.hub_id, 'name' => 'Gothenburg Port', 'nexus' => { 'id' => first_stop.hub.nexus.id, 'name' => 'Gothenburg' }, 'address' => { 'geocoded_address' => '438 80 Landvetter, Sweden', 'latitude' => 57.694253, 'longitude' => 11.854048 } } },
        { 'id' => second_stop.id,
          'created_at' => second_stop.created_at,
          'hub_id' => second_stop.hub_id,
          'index' => 1,
          'itinerary_id' => itinerary.id,
          'sandbox_id' => nil,
          'updated_at' => second_stop.updated_at,
          'hub' => { 'id' => second_stop.hub_id, 'name' => 'Gothenburg Port', 'nexus' => { 'id' => second_stop.hub.nexus.id, 'name' => 'Gothenburg' }, 'address' => { 'geocoded_address' => '438 80 Landvetter, Sweden', 'latitude' => 57.694253, 'longitude' => 11.854048 } } }
      ]

      JSON.parse({ pricings: pricings_table_jsons,
                   itinerary: itinerary,
                   stops: stops_table_jsons }.to_json)
    end

    it 'returns the correct data for the route' do
      get :route, params: { tenant_id: tenant.id, id: itinerary.id }
      expect(JSON.parse(response.body)['data']).to eq(expected_response)
    end
  end

  describe 'POST #upload' do
    context 'when error testing' do
      let(:errors_arr) do
        [{ row_no: 1, reason: 'A' },
         { row_no: 2, reason: 'B' },
         { row_no: 3, reason: 'C' },
         { row_no: 4, reason: 'D' }]
      end
      let(:error) { { has_errors: true, errors: errors_arr } }

      before do
        allow(Legacy::File).to receive(:create!)
        excel_service = instance_double('ExcelDataServices::Loaders::Uploader', perform: error)
        allow(ExcelDataServices::Loaders::Uploader).to receive(:new).and_return(excel_service)
      end

      it 'returns error with messages when an error is raised' do
        post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1 }
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json_response.dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
        end
      end
    end
  end

  describe 'GET #download' do
    let(:tenant) { create(:tenant) }
    let(:hubs) do
      [
        create(:hub,
               tenant: tenant,
               name: 'Gothenburg Port',
               hub_type: 'ocean',
               nexus: create(:nexus, name: 'Gothenburg')),
        create(:hub,
               tenant: tenant,
               name: 'Shanghai Port',
               hub_type: 'ocean',
               nexus: create(:nexus, name: 'Shanghai'))
      ]
    end
    let(:itinerary_with_stops) do
      create(:itinerary, tenant: tenant,
                         stops: [
                           build(:stop, itinerary_id: nil, index: 0, hub: hubs.first),
                           build(:stop, itinerary_id: nil, index: 1, hub: hubs.second)
                         ])
    end
    let(:tenant_vehicle) do
      create(:tenant_vehicle, tenant: tenant)
    end

    before do
      create(:tenants_scope, target: Tenants::Tenant.find_by(legacy_id: tenant.id), content: { 'base_pricing' => true })
    end

    context 'when calculating cargo_item' do
      before do
        create(:lcl_pricing)
        get :download, params: { tenant_id: tenant.id, options: { mot: 'ocean', load_type: 'cargo_item', group_id: nil } }
      end

      it 'returns error with messages when an error is raised' do
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json_response.dig('data', 'url')).to include('demo__pricings_ocean_lcl.xlsx')
        end
      end
    end

    context 'when a container' do
      before do
        create(:fcl_20_pricing)
        get :download, params: { tenant_id: tenant.id, options: { mot: 'ocean', load_type: 'container', group_id: nil } }
      end

      it 'returns error with messages when an error is raised' do
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json_response.dig('data', 'url')).to include('demo__pricings_ocean_fcl.xlsx')
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when base_pricing' do
      before do
        allow(controller).to receive(:current_scope).at_least(:once).and_return({ base_pricing: true }.with_indifferent_access)
        delete :destroy, params: { 'id' => base_pricing.id, tenant_id: tenant.id }
      end

      let(:base_pricing) { create(:pricings_pricing, tenant: tenant) }

      it 'deletes the Pricings::Pricing' do
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(Pricings::Pricing.exists?(id: base_pricing.id)).to eq(false)
        end
      end
    end
  end

  describe 'GET #group' do
    let(:group) do
      FactoryBot.create(:tenants_group, tenant: tenants_tenant).tap do |tapped_group|
        FactoryBot.create(:tenants_membership, group: tapped_group, member: tenants_user)
      end
    end
    let!(:pricing) { FactoryBot.create(:lcl_pricing, itinerary: itinerary, group_id: group.id) }

    before do
      FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true })
      post :group, params: { id: group.id, tenant_id: tenant.id }
    end

    it 'returns an http status of success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns the pricings for the group' do
      json = JSON.parse(response.body)
      expect(json.dig('data', 'pricings', 0, 'id')).to eq(pricing.id.to_s)
    end
  end
end
