# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Users' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:email) { 'test@example.com' }
  let(:password) { 'veryspeciallysecurehorseradish' }

  let(:user) { FactoryBot.create(:tenants_user, email: email, password: password) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }

  get '/v1/me' do
    response_field :id, 'Unique identifier', Type: :UUID
    response_field :email, 'Registetred email address', Type: :String
    response_field :state, <<-DOC, Type: :String
      Current status of the user:

      <dl>
      <dt>pending</dt><dd>User account is pending for email verification</dd>
      <dt>active</dt><dd>User account is active</dd>
      <dt>inactive</dt><dd>User account is inactive and not valid for signin or usage</dd>
      </dl>
    DOC

    example_request 'Returns information of current user' do
      explanation <<-DOC
        Use this endpoint to fetch information of currently signed in user.
      DOC

      expect(status).to eq 200
    end
  end
end
