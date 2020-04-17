# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Authentication' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let(:grant_type) { 'password' }
  let(:email) { user.email }
  let(:password) { 'averysecurehorse' }
  let(:activate) { true }
  let(:user) { FactoryBot.create(:tenants_user, activate: activate, password: password) }

  post '/oauth/token' do
    parameter :grant_type, 'OAuth Grant type to use, always `password`', required: true
    parameter :email, "User's email address", required: true
    parameter :password, "User's Password", required: true
    parameter :client_id, 'Oauth application client id', required: false
    parameter :client_secret, 'Oauth application secret', required: false

    context :success do
      response_field :access_token, 'OAuth token to be used in further connections'
      response_field :token_type, 'OAuth token type'
      response_field :expires_in, 'Time in seconds token is valid'
      response_field :created_at, 'UNIX Timestamp in seconds token was created'

      example_request 'Sign in' do
        explanation 'Request a new OAuth token for further connections by signing in'
        expect(status).to eq 200
      end
    end

    context :errors do
      response_field :error, <<-DOC
        Error code that describes actual error why sign in and token generation has failed.
        <dl>
        <dt>pending_validation</dt><dd>User exists but has not been validated his/hers email address yet.</dd>
        <dt>no_user</dt><dd>User with given email address cannot be found in the system.</dd>
        </dl>
      DOC
      response_field :error_description, ''

      example_request 'Sign in - errors', email: 'foo@example.org' do
        explanation <<-DOC
          Signin can fail for multiple different reasons, mainly user does not exists, is not activated or
          password is invalid.
        DOC

        expect(status).to eq 401
        expect(JSON.parse(response_body)['error']).to eq 'invalid_grant'
      end

      example 'FAIL - Invalid password', document: false do
        do_request password: 'secret'
        expect(status).to eq 401
        expect(JSON.parse(response_body)['error']).to eq 'invalid_grant'
      end
    end

    context :authenticating_with_client do
      let(:legacy_user) { FactoryBot.create(:legacy_user, role: role, password: password) }
      let(:role) { FactoryBot.create(:legacy_role, name: 'admin') }
      let(:admin_user) { Tenants::User.find_by(legacy_id: legacy_user.id) }
      let(:application) { FactoryBot.create(:application, name: 'bridge', scopes: 'admin public') }
      let(:request) do
        {
          email: email,
          password: password,
          client_id: application.uid,
          client_secret: application.secret,
          scope: 'admin',
          grant_type: 'password'
        }
      end

      context :success do
        let(:email) { admin_user.email }

        example 'SUCCESS - Sign in successfully with admin scope' do
          do_request(request)
          expect(status).to eq 200
        end
      end

      context :errors do
        let(:email) { user.email }

        example 'FAIL - logging into admin application without proper roles' do
          do_request(request)
          expect(JSON.parse(response_body)['error']).to eq 'invalid_grant'
        end
      end
    end
  end

  get '/oauth/token/info' do
    example 'Fetch current token' do
      explanation <<-DOC
        Retrieves current token and information about its validity. Should be used after social sign in to fetch actual token securely.
      DOC

      no_doc do
        client.post '/oauth/token', grant_type: grant_type, email: user.email, password: password
        @token = JSON.parse(response_body)['access_token']
      end

      header 'Authorization', "Bearer #{@token}"
      do_request
      expect(status).to eq 200
    end
  end

  delete '/oauth/signout' do
    example 'Signs out current user and revokes OAuth token' do
      explanation 'Use this endpint to sign out current user and revoke OAuth token.'

      no_doc do
        client.post '/oauth/token', grant_type: grant_type, email: user.email, password: password
        @token = JSON.parse(response_body)['access_token']
      end

      header 'Authorization', "Bearer #{@token}"
      do_request
      expect(status).to eq 204

      no_doc do
        # TODO: Send correct header/parameter for actually testing
        client.get '/oauth/token/info'
        expect(status).to eq 401
      end
    end
  end
end
