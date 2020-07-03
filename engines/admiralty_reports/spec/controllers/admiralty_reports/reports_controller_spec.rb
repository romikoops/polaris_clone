# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyReports
  RSpec.describe ReportsController, type: :controller do
    routes { Engine.routes }
    render_views

    let!(:quote_organization) { FactoryBot.create(:organizations_organization, slug: 'demo1') }
    let!(:booking_organization) { FactoryBot.create(:organizations_organization, slug: 'demo2') }
    let!(:user) { FactoryBot.create(:organizations_user, organization: booking_organization) }
    let!(:user_two) { FactoryBot.create(:organizations_user, organization: quote_organization) }
    let!(:quote_organizations_scope) { FactoryBot.create(:organizations_scope, target: quote_organization, content: { open_quotation_tool: true }) }
    let!(:booking_organizations_scope) { FactoryBot.create(:organizations_scope, target: booking_organization, content: { open_quotation_tool: false }) }

    before do
      allow_any_instance_of(AdmiraltyAuth::AuthorizedController).to receive(:authenticate!).and_return(true)
    end

    describe 'GET #index' do
      let!(:organization) { quote_organization }

      it 'renders page' do
        get :index

        expect(response).to be_successful
        expect(response.body).to match(/<td>#{Regexp.quote(Organizations::Organization.find(organization.id).slug)}/im)
      end
    end

    describe 'GET #show' do
      context 'quotation tool' do
        let!(:organization) { quote_organization }

        it 'renders page' do
          get :show, params: { id: organization.id }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(organization.slug)}/im)
        end
      end

      context 'when the results are filtered' do
        before do
          FactoryBot.create(:companies_company, :with_member, organization: quote_organization, member: user_two)
          FactoryBot.create(:companies_company, :with_member, organization: booking_organization, member: user)
          FactoryBot.create(:legacy_quotation,
                            original_shipment_id: shipments.first.id,
                            user: user,
                            updated_at: DateTime.new(2019, 2, 3),
                            created_at: DateTime.new(2019, 2, 2))
          FactoryBot.create(:legacy_quotation,
                            original_shipment_id: shipments.last.id,
                            user: user_two,
                            updated_at: DateTime.new(2019, 2, 3),
                            created_at: DateTime.new(2019, 2, 2))
          ::Quotations::Quotation.create(user_id: user.id, updated_at: DateTime.new(2020, 1, 2), created_at: DateTime.new(2020, 1, 1))
          ::Quotations::Quotation.create(user_id: user_two.id, updated_at: DateTime.new(2020, 1, 2), created_at: DateTime.new(2020, 1, 1))
        end

        let!(:organization) { quote_organization }
        let(:company) { FactoryBot.create(:companies_company) }

        let!(:shipments) do
          [
            FactoryBot.create(:legacy_shipment,
                              user: user,
                              organization_id: quote_organization.id,
                              updated_at: DateTime.new(2019, 2, 3),
                              created_at: DateTime.new(2019, 2, 2)),
            FactoryBot.create(:legacy_shipment,
                              user: user_two,
                              organization_id: quote_organization.id,
                              updated_at: DateTime.new(2019, 2, 5),
                              created_at: DateTime.new(2019, 2, 4))
          ]
        end

        it 'renders page' do
          get :show, params: { id: organization.id, month: '2', year: '2019' }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(organization.slug)}/im)
          expect(response.body).to include('Quotations')
        end

        it 'renders page if it is current month' do
          get :show, params: { id: organization.id, month: Time.zone.now.month, year: Time.zone.now.year }

          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(organization.slug)}/im)
        end
      end

      context 'booking tool' do
        let!(:organization) { booking_organization }
        let!(:user) { FactoryBot.create(:organizations_user, organization_id: quote_organization.id) }

        let!(:shipments) do
          [
            FactoryBot.create(:legacy_shipment,
                              user: user,
                              organization_id: booking_organization.id,
                              updated_at: DateTime.new(2019, 2, 3),
                              created_at: DateTime.new(2019, 2, 2)),
            FactoryBot.create(:legacy_shipment,
                              user: user,
                              organization_id: booking_organization.id,
                              updated_at: DateTime.new(2019, 2, 5),
                              created_at: DateTime.new(2019, 2, 4))
          ]
        end

        it 'renders page' do
          get :show, params: { id: organization.id }
          expect(response).to be_successful
          expect(response.body).to match(/<h2>#{Regexp.quote(organization.slug)}/im)
        end
      end
    end
  end
end
