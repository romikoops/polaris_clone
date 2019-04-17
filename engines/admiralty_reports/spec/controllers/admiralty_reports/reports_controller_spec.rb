# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyReports
  RSpec.describe ReportsController, type: :controller do
    routes { Engine.routes }
    render_views

    before do
      allow_any_instance_of(AdmiraltyAuth::AuthorizedController).to receive(:authenticate_user!).and_return(true)
    end

    let!(:tenants) do
      [
        FactoryBot.create(:legacy_tenant, scope: { 'open_quotation_tool' => true }),
        FactoryBot.create(:legacy_tenant, scope: { 'open_quotation_tool' => false })
      ]
    end

    describe 'GET #index' do
      let(:tenant) { tenants.first }

      it 'renders page' do
        get :index

        expect(response).to be_successful
        expect(response.body).to match(/<td>#{Regexp.quote(tenant.subdomain)}/im)
      end
    end

    describe 'GET #show' do
      context 'quotation tool' do
        let(:tenant) { tenants.first }

        it 'renders page' do
          get :show, params: { id: tenant.id }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(tenant.name)}/im)
        end
      end

      context 'booking tool' do
        let(:tenant) { tenants.second }

        it 'renders page' do
          get :show, params: { id: tenant.id }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(tenant.name)}/im)
        end
      end
    end
  end
end
