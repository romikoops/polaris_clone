# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyReports
  RSpec.describe ReportsController, type: :controller do
    routes { Engine.routes }
    render_views

    before do
      allow_any_instance_of(AdmiraltyAuth::AuthorizedController).to receive(:authenticate!).and_return(true)
    end

    let!(:quote_tenant) { FactoryBot.create(:legacy_tenant, name: 'Demo1', subdomain: 'demo1') }
    let!(:booking_tenant) { FactoryBot.create(:legacy_tenant, name: 'Demo2', subdomain: 'demo2') }

    let!(:quote_tenants_tenant) { Tenants::Tenant.find_by(legacy_id: quote_tenant.id) }
    let!(:booking_tenants_tenant) { Tenants::Tenant.find_by(legacy_id: booking_tenant.id) }

    let!(:quote_tenants_scope) { FactoryBot.create(:tenants_scope, target: quote_tenants_tenant, content: { open_quotation_tool: true }) }
    let!(:booking_tenants_scope) { FactoryBot.create(:tenants_scope, target: booking_tenants_tenant, content: { open_quotation_tool: false }) }

    describe 'GET #index' do
      let!(:tenant) { quote_tenant }

      it 'renders page' do
        get :index

        expect(response).to be_successful
        expect(response.body).to match(/<td>#{Regexp.quote(Tenant.find_by(legacy_id: tenant.id).slug)}/im)
      end
    end

    describe 'GET #show' do
      context 'quotation tool' do
        let!(:tenant) { quote_tenant }

        it 'renders page' do
          get :show, params: { id: Tenant.find_by(legacy_id: tenant.id).id }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(tenant.name)}/im)
        end
      end

      context 'when the results are filtered' do
        before do
          tenants_user.update(company: company)
          tenants_user_two.update(company: company)
          FactoryBot.create(:legacy_quotation,
                            original_shipment_id: shipments.first.id,
                            user_id: user.id,
                            updated_at: DateTime.new(2019, 2, 3),
                            created_at: DateTime.new(2019, 2, 2))
          FactoryBot.create(:legacy_quotation,
                            original_shipment_id: shipments.last.id,
                            user_id: user_two.id,
                            updated_at: DateTime.new(2019, 2, 3),
                            created_at: DateTime.new(2019, 2, 2))
          ::Quotations::Quotation.create(user_id: user.id, updated_at: DateTime.new(2020, 1, 2), created_at: DateTime.new(2020, 1, 1))
          ::Quotations::Quotation.create(user_id: user_two.id, updated_at: DateTime.new(2020, 1, 2), created_at: DateTime.new(2020, 1, 1))
        end

        let!(:tenant) { quote_tenant }
        let(:company) { FactoryBot.create(:tenants_company) }
        let!(:user) { FactoryBot.create(:legacy_user, tenant_id: quote_tenant.id) }
        let!(:user_two) { FactoryBot.create(:legacy_user, tenant_id: quote_tenant.id) }
        let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
        let!(:tenants_user_two) { Tenants::User.find_by(legacy_id: user_two.id) }

        let!(:shipments) do
          [
            FactoryBot.create(:legacy_shipment,
                              user_id: user.id,
                              tenant_id: quote_tenant.id,
                              updated_at: DateTime.new(2019, 2, 3),
                              created_at: DateTime.new(2019, 2, 2)),
            FactoryBot.create(:legacy_shipment,
                              user_id: user_two.id,
                              tenant_id: quote_tenant.id,
                              updated_at: DateTime.new(2019, 2, 5),
                              created_at: DateTime.new(2019, 2, 4))
          ]
        end

        it 'renders page' do
          get :show, params: { id: Tenant.find_by(legacy_id: tenant.id).id, month: '2', year: '2019' }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(tenant.name)}/im)
          expect(response.body).to include('Quotations')
        end

        it 'renders page if it is current month' do
          get :show, params: { id: Tenant.find_by(legacy_id: tenant.id).id, month: Time.zone.now.month, year: Time.zone.now.year }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(tenant.name)}/im)
        end
      end

      context 'booking tool' do
        let!(:tenant) { booking_tenant }
        let!(:user) { FactoryBot.create(:legacy_user, tenant_id: quote_tenant.id) }

        let!(:shipments) do
          [
            FactoryBot.create(:legacy_shipment,
                              user_id: user.id,
                              tenant_id: booking_tenant.id,
                              updated_at: DateTime.new(2019, 2, 3),
                              created_at: DateTime.new(2019, 2, 2)),
            FactoryBot.create(:legacy_shipment,
                              user_id: user.id,
                              tenant_id: booking_tenant.id,
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
