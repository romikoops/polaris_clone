# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::PricingsController, type: :controller do
  describe 'GET #route' do
    before do
      user_double = double('User', guest: false,
                                   email: 'test@test.com',
                                   id: 1,
                                   agency_id: nil,
                                   agency: nil,
                                   tenant: nil,
                                   groups: nil,
                                   company: nil,
                                   scope: nil,
                                   sandbox: nil,
                                   internal: false)
      expect_any_instance_of(described_class).to receive(:require_authentication!).and_return(true)
      expect_any_instance_of(described_class).to receive(:require_non_guest_authentication!).and_return(true)
      expect_any_instance_of(described_class).to receive(:require_login_and_role_is_admin).and_return(true)
      expect_any_instance_of(described_class).to receive(:current_user).at_least(:once).and_return(user_double)
      expect(user_double).to receive(:tenant_scope).and_return('base_pricing' => true)
    end

    let(:tenant) { FactoryBot.create(:legacy_tenant) }
    let(:itinerary) do
      FactoryBot.create(:itinerary, tenant_id: tenant.id)
    end
    let!(:pricings) do
      [
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
          'hub' => { 'id' => first_stop.hub_id, 'name' => 'Gothenburg Port', 'available_trucking' => [], 'nexus' => { 'id' => first_stop.hub.nexus.id, 'name' => 'Gothenburg' }, 'address' => { 'geocoded_address' => '438 80 Landvetter, Sweden', 'latitude' => 57.694253, 'longitude' => 11.854048 } } },
        { 'id' => second_stop.id,
          'created_at' => second_stop.created_at,
          'hub_id' => second_stop.hub_id,
          'index' => 1,
          'itinerary_id' => itinerary.id,
          'sandbox_id' => nil,
          'updated_at' => second_stop.updated_at,
          'hub' => { 'id' => second_stop.hub_id, 'name' => 'Gothenburg Port', 'available_trucking' => [], 'nexus' => { 'id' => second_stop.hub.nexus.id, 'name' => 'Gothenburg' }, 'address' => { 'geocoded_address' => '438 80 Landvetter, Sweden', 'latitude' => 57.694253, 'longitude' => 11.854048 } } }
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
    context 'error testing' do
      let(:errors_arr) do
        [{ row_no: 1, reason: 'A' },
         { row_no: 2, reason: 'B' },
         { row_no: 3, reason: 'C' },
         { row_no: 4, reason: 'D' }]
      end
      let(:error) { { has_errors: true, errors: errors_arr } }

      before do
        expect_any_instance_of(described_class).to receive(:require_authentication!).and_return(true)
        expect_any_instance_of(described_class).to receive(:require_non_guest_authentication!).and_return(true)
        expect_any_instance_of(described_class).to receive(:require_login_and_role_is_admin).and_return(true)
        expect_any_instance_of(described_class).to receive(:current_tenant).at_least(:once).and_return(double('Tenant', scope: {}, subdomain: 'test', id: 1))
        expect_any_instance_of(described_class).to receive(:current_user).at_least(:once).and_return(double('User', guest: false, email: 'test@test.com', id: 1, agency_id: nil, agency: nil, tenant: nil, groups: nil, company: nil, scope: nil, sandbox: nil))
        expect(Document).to receive(:create!)
        expect_any_instance_of(ExcelDataServices::Loaders::Uploader).to receive(:perform).and_return(error)
      end

      it 'returns error with messages when an error is raised' do
        post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1, mot: 'ocean', load_type: 'cargo_item' }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
      end
    end
  end
end
