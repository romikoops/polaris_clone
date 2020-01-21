# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyAuth
  RSpec.describe LoginsController, type: :controller do
    routes { Engine.routes }
    render_views

    describe 'GET #new' do
      it 'renders page' do
        get :new

        aggregate_failures do
          expect(response).to be_successful
          expect(response.body).to match(/Sign in with GSuite/im)
        end
      end
    end

    describe 'POST #create' do
      let(:hosted_domain) { 'itsmycargo.com' }
      let(:google_identity) do
        instance_double('GoogleSignIn::Identity', hosted_domain: hosted_domain)
      end

      before do
        allow_any_instance_of(described_class).to receive(:flash).and_return(google_sign_in_token: 'GOOGL')
        session[:return_to_url] = '/'
        allow(GoogleSignIn::Identity).to receive(:new).and_return(google_identity)
      end

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

    describe 'DELETE #destroy' do
      before do
        session[:last_activity_at] = Time.zone.now
      end

      it 'signs out successfully' do
        delete :destroy

        expect(response).to redirect_to('/login')
      end
    end
  end
end
