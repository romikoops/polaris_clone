# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::PricingsController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization, slug: 'demo') }
  let(:user) { FactoryBot.create(:users_user) }
  let(:itinerary) do
    FactoryBot.create(:itinerary, organization_id: organization.id)
  end
  let(:json_response) { JSON.parse(response.body) }

  before do
    append_token_header
  end

  describe 'GET #route' do
    before do
      allow(controller).to receive(:current_scope).at_least(:once).and_return('base_pricing' => true)
    end

    let!(:pricings) do
      [
        FactoryBot.create(:pricings_pricing, organization_id: organization.id, itinerary_id: itinerary.id),
        FactoryBot.create(:pricings_pricing, organization_id: organization.id,
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
          'organization_id' => organization.id,
          'tenant_vehicle_id' => pricings.first.tenant_vehicle_id,
          'wm_rate' => '1000.0',
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
          'hub_id' => first_stop.hub_id,
          'index' => 0,
          'itinerary_id' => itinerary.id,
          'hub' => { 'id' => first_stop.hub_id, 'name' => 'Gothenburg', 'nexus' => { 'id' => first_stop.hub.nexus.id, 'name' => 'Gothenburg' }, 'address' => { 'geocoded_address' => '438 80 Landvetter, Sweden', 'latitude' => 57.694253, 'longitude' => 11.854048 } } },
        { 'id' => second_stop.id,
          'hub_id' => second_stop.hub_id,
          'index' => 1,
          'itinerary_id' => itinerary.id,
          'hub' => { 'id' => second_stop.hub_id, 'name' => 'Gothenburg', 'nexus' => { 'id' => second_stop.hub.nexus.id, 'name' => 'Gothenburg' }, 'address' => { 'geocoded_address' => '438 80 Landvetter, Sweden', 'latitude' => 57.694253, 'longitude' => 11.854048 } } }
      ]

      JSON.parse({ pricings: pricings_table_jsons,
                   itinerary: itinerary,
                   stops: stops_table_jsons }.to_json)
    end

    it 'returns the correct data for the route' do
      get :route, params: { organization_id: organization.id, id: itinerary.id }
      expect(JSON.parse(response.body)['data']).to eq(expected_response)
    end
  end

  describe 'POST #upload' do
    let(:perform_request) { post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), organization_id: organization.id } }

    context 'when error testing' do
      let(:errors_arr) do
        [{ row_no: 1, reason: 'A' },
         { row_no: 2, reason: 'B' },
         { row_no: 3, reason: 'C' },
         { row_no: 4, reason: 'D' }]
      end
      let(:error) { { has_errors: true, errors: errors_arr } }

      let(:complete_email_job) { performed_jobs.find { |j| j[:args][0] == "UploadMailer" } }
      let(:resulted_errors) { complete_email_job[:args][3]['result']['errors'].map { |err| err.except('_aj_symbol_keys') } }

      before do
        excel_service = instance_double('ExcelDataServices::Loaders::Uploader', perform: error)
        allow(ExcelDataServices::Loaders::Uploader).to receive(:new).and_return(excel_service)

        allow(controller).to receive(:current_organization).and_return(organization)
      end

      it_behaves_like 'uploading request async'

      it 'sends an email with the upload errors' do
        perform_enqueued_jobs do
          perform_request
        end

        expect(resulted_errors).to eq(JSON.parse(errors_arr.to_json))
      end
    end
  end

  describe 'GET #download' do
    let(:organization) { create(:organizations_organization, slug: 'demo') }
    let(:hubs) do
      [
        create(:hub,
               organization: organization,
               name: 'Gothenburg',
               hub_type: 'ocean',
               nexus: create(:nexus, name: 'Gothenburg')),
        create(:hub,
               organization: organization,
               name: 'Shanghai',
               hub_type: 'ocean',
               nexus: create(:nexus, name: 'Shanghai'))
      ]
    end
    let(:itinerary_with_stops) do
      create(:itinerary, organization: organization,
                         stops: [
                           build(:stop, itinerary_id: nil, index: 0, hub: hubs.first),
                           build(:stop, itinerary_id: nil, index: 1, hub: hubs.second)
                         ])
    end
    let(:tenant_vehicle) do
      create(:tenant_vehicle, organization: organization)
    end

    before do
      create(:organizations_scope, target: organization, content: { 'base_pricing' => true })
    end

    context 'when calculating cargo_item' do
      before do
        create(:lcl_pricing)
        get :download, params: { organization_id: organization.id, options: { mot: 'ocean', load_type: 'cargo_item', group_id: nil } }
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
        get :download, params: { organization_id: organization.id, options: { mot: 'ocean', load_type: 'container', group_id: nil } }
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
        delete :destroy, params: { 'id' => base_pricing.id, organization_id: organization.id }
      end

      let(:base_pricing) { create(:pricings_pricing, organization: organization) }

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
      FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
        FactoryBot.create(:groups_membership, group: tapped_group, member: user)
      end
    end
    let!(:pricing) { FactoryBot.create(:lcl_pricing, itinerary: itinerary, group_id: group.id) }

    before do
      FactoryBot.create(:organizations_scope, target: organization, content: { base_pricing: true })
      post :group, params: { id: group.id, organization_id: organization.id }
    end

    it 'returns an http status of success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns the pricings for the group' do
      json = JSON.parse(response.body)
      expect(json.dig('data', 'pricings', 0, 'id')).to eq(pricing.id.to_s)
    end
  end

  describe 'POST #disable' do
    let(:pricing) { FactoryBot.create(:pricings_pricing, organization_id: organization.id, itinerary_id: itinerary.id) }

    context "when enabling pricing" do
      before do
        pricing.update(internal: true)
      end

      it "toggles the internal state of the pricing to true" do
        post :disable, params: {pricing_id: pricing.id, id: pricing.id, organization_id: organization.id, target_action: 'enable'}
        aggregate_failures do
          expect(response).to have_http_status(:success)
          pricing.reload
          expect(pricing.internal).to eq(false)
        end
      end
    end

    context "when disabling pricing'" do
      before do
        pricing.update(internal: false)
      end

      it "toggles the internal state of the pricing to true" do
        post :disable, params: {pricing_id: pricing.id, id: pricing.id, organization_id: organization.id, target_action: 'disable'}
        aggregate_failures do
          expect(response).to have_http_status(:success)
          pricing.reload
          expect(pricing.internal).to eq(true)
        end
      end
    end
  end
end
