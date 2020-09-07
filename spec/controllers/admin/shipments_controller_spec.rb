# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ShipmentsController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:organizations_membership) { FactoryBot.create(:organizations_membership, role: :admin, organization: organization, member: user) }
  let!(:shipper) { create(:organizations_user, organization_id: organization.id) }
  let!(:profile) { create(:profiles_profile, user: shipper) }
  let!(:shipment) { FactoryBot.create(:completed_legacy_shipment, with_breakdown: true, with_tenders: true, organization: organization, user: shipper, status: 'requested') }
  let(:charge_breakdown) { shipment.charge_breakdowns.selected }
  let(:breakdown) { FactoryBot.build(:pricings_breakdown) }
  let(:user_breakdown) { FactoryBot.build(:pricings_breakdown, target: user) }
  let(:parsed_response) { JSON.parse(response.body) }

  before do
    ::Organizations.current_id = organization.id
    append_token_header
  end

  describe 'GET #index' do
    it 'returns an http status of success' do
      get :index, params: { organization_id: organization }

      expect(response).to have_http_status(:success)
    end

    context 'when a user has been deleted' do
      before do
        user.destroy
      end

      it 'returns an http status of success' do
        get :index, params: { organization_id: organization.id }

        expect(response).to have_http_status(:success)
      end
    end

    context 'when a user is nil' do
      let!(:nil_user_shipment) {
        FactoryBot.create(:completed_legacy_shipment, with_breakdown: true, with_tenders: true, organization: organization, user: nil, status: 'requested')
      }

      it 'returns an http status of success' do
        get :index, params: { organization_id: organization.id }
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json.dig(:data, :requested).pluck(:id)).to include(nil_user_shipment.id)
        end
      end
    end
  end

  describe 'GET #search_shipments' do
    it 'returns the matching shipments for the guest user' do
      get :search_shipments, params: { target: 'requested', query: profile.first_name, organization_id: organization.id }
      expected_client_name = "#{profile.first_name} #{profile.last_name}"
      expect(json.dig(:data, :shipments).first[:client_name]).to eq(expected_client_name)
    end

    context 'when searching via POL' do
      it 'returns matching shipments with origin matching the query' do
        get :search_shipments, params: { target: 'requested', query: shipment.origin_hub.name, organization_id: organization.id }
        expect(json.dig(:data, :shipments).first[:id]).to eq(shipment.id)
      end
    end

    context "when searching via user's company name/Agency" do
      it 'returns matching shipments with users matching the company name in query' do
        get :search_shipments, params: { target: 'requested', query: profile.company_name, organization_id: organization.id }
        expect(json.dig(:data, :shipments).first[:id]).to eq(shipment.id)
      end
    end
  end

  describe 'GET #show' do
    before do
      allow(Pricings::Metadatum).to receive(:find_by).and_return(instance_double('Pricings::Metadatum', breakdowns: [breakdown, user_breakdown]))
    end

    context 'with charge breakdowns' do
      before do
        allow(shipment).to receive(:selected_offer).and_return({})
        allow(shipment).to receive('charge_breakdowns').and_return(object_double(selected: charge_breakdown))
        get :show, params: { id: shipment.id, organization_id: organization.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the shipment object sent in the parameters' do
        aggregate_failures do
          expect(parsed_response['data']['shipment']['id']).to eq(shipment.id)
          expect(parsed_response['data'].keys).to match_array(%w[shipment cargoItems containers aggregatedCargo contacts documents addresses cargoItemTypes accountHolder pricingBreakdowns])
        end
      end
    end

    context 'without charge breakdowns' do
      before do
        allow(shipment).to receive(:selected_offer).and_return({})
        allow(shipment).to receive('charge_breakdowns').and_return(object_double(selected: {}))
        get :show, params: { id: shipment.id, organization_id: organization.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the shipment object sent in the parameters' do
        aggregate_failures do
          expect(parsed_response['data']['shipment']['id']).to eq(shipment.id)
          expect(parsed_response['data'].keys).to match_array(%w[shipment cargoItems containers aggregatedCargo contacts documents addresses cargoItemTypes accountHolder pricingBreakdowns])
        end
      end
    end
  end

  describe 'POST #upload_client_document' do
    before do
      post :upload_client_document, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), shipment_id: shipment.id, organization_id: organization.id, type: 'packing_sheet' }
    end

    it 'returns the document with the signed url' do
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(parsed_response.dig('data', 'signed_url')).to be_truthy
      end
    end
  end

  describe 'POST #document_action' do
    let(:file) { FactoryBot.create(:legacy_file, shipment: shipment) }

    before do
      post :document_action, params: { id: file.id, shipment_id: shipment.id, organization_id: organization.id, type: 'approve' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns approves the document and returns it' do
      aggregate_failures do
        expect(parsed_response['data']).not_to be_empty
        expect(parsed_response.dig('data', 'approved')).to eq('approved')
      end
    end
  end

  describe 'POST #update' do
    let(:action) { 'accept' }

    before do
      post :update, params: { id: shipment.id, organization_id: organization.id, shipment_action: action }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    context 'when confirming' do
      it 'returns approves the document and returns it' do
        aggregate_failures do
          expect(json.dig(:data, :status)).to eq('confirmed')
        end
      end
    end

    context 'when declining' do
      let(:action) { 'decline' }

      it 'returns approves the document and returns it' do
        aggregate_failures do
          expect(json.dig(:data, :status)).to eq('declined')
        end
      end
    end

    context 'when ignoring' do
      let(:action) { 'ignore' }

      it 'returns approves the document and returns it' do
        aggregate_failures do
          expect(json.dig(:data, :status)).to eq('ignored')
        end
      end
    end

    context 'when archiving' do
      let(:action) { 'archive' }

      it 'returns approves the document and returns it' do
        aggregate_failures do
          expect(json.dig(:data, :status)).to eq('archived')
        end
      end
    end

    context 'when finished' do
      let(:action) { 'finished' }

      it 'returns approves the document and returns it' do
        aggregate_failures do
          expect(json.dig(:data, :status)).to eq('finished')
        end
      end
    end

    context 'when request' do
      let(:action) { 'requested' }

      it 'returns approves the document and returns it' do
        aggregate_failures do
          expect(json.dig(:data, :status)).to eq('requested')
        end
      end
    end
  end

  describe 'POST #document_delete' do
    let(:file) { FactoryBot.create(:legacy_file, shipment: shipment) }

    it 'deletes the document' do
      post :document_delete, params: { id: file.id, shipment_id: shipment.id, organization_id: organization.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(Legacy::File.find_by(id: file.id)).to be_nil
      end
    end

    context "when document does not exist" do
      it "returns http status not found" do
        post :document_delete, params: { id: "wrong_id", shipment_id: shipment.id, organization_id: organization.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #edit_service_price' do
    let(:params) {
      {
        id: shipment.id,
        organization_id: organization.id,
        price: {
          value: 200,
          currency: 'USD'
        },
        charge_category: 'cargo'
      }
    }
    let(:charge_breakdown) { shipment.charge_breakdowns.selected }
    let(:tender) { charge_breakdown.tender }

    it 'updates the charge' do
      post :edit_service_price, params: params

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(charge_breakdown.charge('cargo').edited_price.money).to eq(Money.new(20000, 'USD'))
        expect(charge_breakdown.grand_total.edited_price.money.cents.round).to eq(tender.amount.cents.round)
      end
    end
  end

  describe 'GET #delta_page_handler' do
    before { shipment.update(status: 'quoted') }

    it 'returns shipments matching the target in params' do
      get :delta_page_handler, params: { target: 'quoted', organization_id: organization.id }
      expect(json.dig(:data, :shipments).count).to eq(1)
    end
  end
end
