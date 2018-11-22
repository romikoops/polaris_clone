# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyAuth
  RSpec.describe LoginsController, type: :controller do
    routes { Engine.routes }
    render_views

    describe 'GET #new' do
      it 'renders page' do
        get :new

        expect(response).to be_successful
        expect(response.body).to match(/Sign in with my Google account/im)
      end
    end

    describe 'POST #create' do
      let(:user) { FactoryBot.create(:users_user, google_id: 'GOOGL') }
      let(:hosted_domain) { 'itsmycargo.com' }
      let(:google_identity) do
        double('GoogleSignIn::Identity', hosted_domain: hosted_domain, user_id: 'GOOGL', email_address: user.email, name: user.name)
      end

      before do
        allow_any_instance_of(described_class).to receive(:flash).and_return(google_sign_in_token: 'GOOGL')
        allow_any_instance_of(described_class).to receive(:session).and_return(return_to_url: '/')
        allow(GoogleSignIn::Identity).to receive(:new).and_return(google_identity)
      end

      context 'existing user' do
        it 'logins successfully' do
          post :create

          expect(response).to redirect_to('/')
        end

        it 'fails login' do
          expect_any_instance_of(described_class).to receive(:authenticate_with_google).and_return(nil)

          post :create

          expect(response).to redirect_to('/login')
        end
      end

      context 'new user' do
        let(:email) { "#{SecureRandom.hex}@itsmycargo.test" }
        let(:user) { FactoryBot.build(:users_user, email: email) }

        it 'logins successfully' do
          post :create

          expect(response).to redirect_to('/')
          expect(Users::User.exists?(email: email)).to be_truthy
        end
      end
    end
  end
end
