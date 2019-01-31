# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Authentication' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let(:grant_type) { 'password' }
  let(:email) { user.email }
  let(:password) { 'averysecurehorse' }
  let(:activate) { true }
  let(:user) { FactoryGirl.create(:tenants_user, activate: activate, password: password) }

  post '/oauth/token' do
    parameter :grant_type, 'OAuth Grant type to use, always `password`', required: true
    parameter :email, "User's email address", required: true
    parameter :password, "User's Password", required: true

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
        expect(JSON.parse(response_body)['error']).to eq 'no_user'
      end

      example 'FAIL - Invalid password', document: false do
        do_request password: 'secret'
        expect(status).to eq 401
        expect(JSON.parse(response_body)['error']).to eq 'invalid_grant'
      end

      context 'Unactivated user' do
        let(:activate) { false }

        example 'FAIL - Unvalidated user', document: false do
          do_request
          expect(status).to eq 401
          expect(JSON.parse(response_body)['error']).to eq 'pending_validation'
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
        @token = response_headers['X-Access-Token']
      end

      header 'Cookie', "token=#{@token}"
      do_request
      expect(status).to eq 200
    end
  end

  delete '/oauth/signout' do
    example 'Signs out current user and revokes OAuth token' do
      explanation 'Use this endpint to sign out current user and revoke OAuth token.'

      no_doc do
        client.post '/oauth/token', grant_type: grant_type, email: user.email, password: password
        @token = response_headers['X-Access-Token']
      end

      header 'Cookie', "token=#{@token}"
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
