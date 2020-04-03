# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Dashboard' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header
  let(:email) { 'test3@example.com' }
  let(:password) { 'veryspeciallysecurehorseradish' }
  let!(:quote_tenant) { ::Legacy::Tenant.create(name: 'Demo1', subdomain: 'demo1', scope: { open_quotation_tool: true }) }
  let!(:tenant) { FactoryBot.create(:tenants_tenant, legacy_id: quote_tenant.id) }

  let(:legacy_user) { FactoryBot.create(:legacy_user, tenant: quote_tenant, email: 't@example.com') }
  let(:user) { Tenants::User.find_by(legacy_id: legacy_user.id) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }
  let(:start_date) { DateTime.new(2020, 2, 10) }
  let(:shipment_date) { DateTime.new(2020, 2, 20) }
  let(:end_date) { DateTime.new(2020, 3, 10) }

  get '/v1/dashboard' do
    parameter :user, 'The user who is accessing their dashboard'
    parameter :widget, 'The widget specific widget that they are trying to access on the dashboard'
    parameter :start_date, 'The start date provided by the filtering of the user'
    parameter :end_date, 'The end date provided by the filtering of the user'

    example 'Returns information for a provided widget' do
      explanation <<-DOC
        The user attempts to access the data needed for a given widget while logging on to the bridge dashboard
      DOC
      request = { user: user, widget: 'activeClientCount', start_date: end_date, end_date: end_date }
      do_request(request)
      expect(status).to eq 200
    end
  end
end
