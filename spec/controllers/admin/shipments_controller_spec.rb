# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ShipmentsController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:user) { create(:legacy_user, tenant: tenant, email: 'user@itsmycargo.com', role: role) }
  let!(:role) { create(:role, name: 'shipper') }
  let(:shipment) { FactoryBot.create(:shipment) }
  let(:charge_breakdown) { FactoryBot.create(:charge_breakdown, shipment: shipment) }
  let(:breakdown) { FactoryBot.build(:pricings_breakdown) }

  describe 'GET #index' do
    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'returns an http status of success' do
      get :index, params: { tenant_id: tenant }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:append_info_to_payload).and_return(true)

      allow(Pricings::Metadatum).to receive(:find_by).and_return(double(breakdowns: [ breakdown ]))
    end

    context 'with charge breakdowns' do
      before do
        allow_any_instance_of(Shipment).to receive(:selected_offer).and_return({})
        allow_any_instance_of(Shipment).to receive('charge_breakdowns').and_return(double(selected: charge_breakdown))
      end

      it 'returns the shipment object sent in the parameters' do
        get :show, params: { id: shipment.id, tenant_id: tenant.id }

        expect(response).to have_http_status(:success)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['data']['shipment']['id']).to eq(shipment.id)
        %w(cargoItems containers aggregatedCargo contacts documents addresses cargoItemTypes accountHolder pricingBreakdowns).each do |key|
          expect(parsed_response['data']).to have_key(key)
        end
      end
    end

    context 'without charge breakdowns' do
      before do
        allow_any_instance_of(Shipment).to receive(:selected_offer).and_return({})
        allow_any_instance_of(Shipment).to receive('charge_breakdowns').and_return(double(selected: nil))
      end

      it 'returns the shipment object sent in the parameters' do
        get :show, params: { id: shipment.id, tenant_id: tenant.id }

        expect(response).to have_http_status(:success)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['data']['shipment']['id']).to eq(shipment.id)
        %w(cargoItems containers aggregatedCargo contacts documents addresses cargoItemTypes accountHolder pricingBreakdowns).each do |key|
          expect(parsed_response['data']).to have_key(key)
        end
      end
    end
  end
end
