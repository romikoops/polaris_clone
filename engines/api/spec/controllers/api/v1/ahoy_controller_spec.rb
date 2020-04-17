# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::AhoyController, type: :controller do
    routes { Engine.routes }
    let(:tenant) { FactoryBot.create(:tenants_tenant) }

    before { FactoryBot.create(:tenants_domain, tenant: tenant, default: true) }

    describe 'GET #settings' do
      it 'returns the settings of the tenant' do
        get :settings, params: { id: tenant.id }, as: :json

        aggregate_failures do
          expect(response).to be_successful
          expect(response.body).not_to be_empty

          data = JSON.parse(response.body)
          expect(data).not_to be_nil
        end
      end

      it 'returns 404 if tenant does not exist' do
        get :settings, params: { id: 'Invalid Tenant UUID' }, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
