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
        ::Legacy::Tenant.create(name: 'Demo1', subdomain: 'demo1', scope: { 'open_quotation_tool' => true }),
        ::Legacy::Tenant.create(name: 'Demo2', subdomain: 'demo2', scope: { 'open_quotation_tool' => false })
      ]
    end
    let!(:tenants_tenants_true) { ::Tenants::Tenant.find_by(slug: 'demo1') }
    let!(:tenants_tenants_false) { ::Tenants::Tenant.find_by(slug: 'demo2') }

    let!(:scopes) do
      [
        ::Tenants::Scope.create(target: tenants_tenants_true, content: { 'open_quotation_tool' => true }),
        ::Tenants::Scope.create(target: tenants_tenants_false, content: { 'open_quotation_tool' => false })
      ]
    end

    describe 'GET #index' do
      let!(:tenant) { tenants.first }

      it 'renders page' do
        get :index

        expect(response).to be_successful
        expect(response.body).to match(/<td>#{Regexp.quote(Tenant.find_by(legacy_id: tenant.id).slug)}/im)
      end
    end

    describe 'GET #show' do
      context 'quotation tool' do
        let!(:tenant) { tenants.first }

        it 'renders page' do
          get :show, params: { id: Tenant.find_by(legacy_id: tenant.id).id }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(tenant.name)}/im)
        end
      end

      context 'filtered results ' do
        let!(:tenant) { tenants.first }
        let!(:agency) { FactoryBot.create(:legacy_agency) }
        let!(:user) { FactoryBot.create(:legacy_user, tenant_id: tenants.first.id, company_name: nil, agency: agency) }
        let!(:shipments) do
          [
            FactoryBot.create(:legacy_shipment,
                              user_id: user.id,
                              tenant_id: tenants.first.id,
                              updated_at: DateTime.new(2019, 2, 3),
                              created_at: DateTime.new(2019, 2, 2)),
            FactoryBot.create(:legacy_shipment,
                              user_id: user.id,
                              tenant_id: tenants.first.id,
                              updated_at: DateTime.new(2019, 2, 5),
                              created_at: DateTime.new(2019, 2, 4))
          ]
        end
        let!(:quotations) do
          [
            FactoryBot.create(:legacy_quotation,
                              original_shipment_id: shipments.first.id,
                              user_id: user.id,
                              updated_at: DateTime.new(2019, 2, 3),
                              created_at: DateTime.new(2019, 2, 2)),
            FactoryBot.create(:legacy_quotation,
                              original_shipment_id: shipments.last.id,
                              user_id: user.id,
                              updated_at: DateTime.new(2019, 2, 5),
                              created_at: DateTime.new(2019, 2, 4))
          ]
        end

        it 'renders page' do
          get :show, params: { id: Tenant.find_by(legacy_id: tenant.id).id, month: '2', year: '2019' }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(tenant.name)}/im)
        end

        it 'renders page if it is current month' do
          get :show, params: { id: Tenant.find_by(legacy_id: tenant.id).id, month: Time.now.month, year: Time.now.year }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(tenant.name)}/im)
        end
      end

      context 'booking tool' do
        let!(:tenant) { tenants.second }
        let!(:user) { FactoryBot.create(:legacy_user, tenant_id: tenants.first.id, company_name: nil) }

        let!(:shipments) do
          [
            FactoryBot.create(:legacy_shipment,
                              user_id: user.id,
                              tenant_id: tenants.second.id,
                              updated_at: DateTime.new(2019, 2, 3),
                              created_at: DateTime.new(2019, 2, 2)),
            FactoryBot.create(:legacy_shipment,
                              user_id: user.id,
                              tenant_id: tenants.second.id,
                              updated_at: DateTime.new(2019, 2, 5),
                              created_at: DateTime.new(2019, 2, 4))
          ]
        end

        it 'renders page' do
          get :show, params: { id: Tenant.find_by(legacy_id: tenant.id).id }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(tenant.name)}/im)
        end
      end
    end
  end
end
