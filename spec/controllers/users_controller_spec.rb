# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController do
  let(:addresses) { create_list(:address, 5) }
  let(:organization) { create(:organizations_organization) }
  let!(:user) { create(:authentication_user, :organizations_user, organization_id: organization.id) }
  let(:domain) { create(:organizations_domain, organization: organization, domain: 'itsmycargo.example') }

  before do
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700").to_return(status: 200, body: "", headers: {})

    request.env["HTTP_REFERER"] = "http://#{domain.domain}"
    Organizations.current_id = organization.id
    append_token_header
    FactoryBot.create(:profiles_profile, user_id: user.id)
    addresses.each do |address|
      FactoryBot.create(:legacy_user_address, user_id: user.id, address: address)
    end
  end

  describe 'GET #home' do
    it 'returns an http status of success' do
      get :home, params: { organization_id: user.organization_id, user_id: user.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'returns an http status of success' do
      get :show, params: { organization_id: user.organization_id, user_id: user.id }
      aggregate_failures do
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body.dig('data', 'id')).to eq(user.id)
        expect(body.dig('data', 'inactivityLimit')).to eq(86_400)
      end
    end
  end

  describe 'POST #create' do
    before do
      create(:organizations_theme, organization: organization)
    end

    let(:test_email) { 'test@itsmycargo.com' }
    let(:created_user) { Organizations::User.find_by(email: test_email, organization: organization) }

    it 'creates a new user' do
      params = {
        user: {
          email: test_email,
          password: '123456789',
          organization_id: user.organization_id,
          company_name: 'Person Freight',
          first_name: 'Test',
          last_name: 'Person',
          phone: '01628710344'
        }
      }
      post :create, params: params
      expect(response).to have_http_status(:success)
    end

    context 'when creating with no profile attributes' do
      let(:params) do
        {
          user: {
            email: test_email,
            password: '123456789',
            organization_id: user.organization_id
          }
        }
      end

      it 'returns http status and updates the user' do
        post :create, params: params
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(Profiles::Profile.exists?(user: created_user)).to be_truthy
        end
      end
    end

    context 'when creating with wrong params' do
      let(:params) do
        {
          user: {
            email: nil,
            password: '123456789',
            organization_id: user.organization_id
          }
        }
      end

      it 'raises ActiveRecord::RecordInvalid' do
        post :create, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST #update' do
    it 'returns http success, updates the user and send the email' do
      params = {
        organization_id: user.organization_id,
        user_id: user.id,
        update: {
          company_name: 'Person Freight',
          company_number: 'Person Freight',
          email: 'wkbeamish+123@gmail.com',
          first_name: 'Test',
          guest: false,
          last_name: 'Person',
          phone: '01628710344',
          organization_id: user.organization_id
        }
      }
      post :update, params: params
      expect(response).to have_http_status(:success)
    end

    context 'when updating with no profile attributes' do
      let(:params) do
        {
          organization_id: user.organization_id,
          user_id: user.id,
          update: {
            guest: true
          }
        }
      end

      it 'returns http status and updates the user' do
        post :update, params: params
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /activate" do
    it "returns http success" do
      user.setup_activation
      user.save

      get :activate, params: {organization_id: organization.id, id: user.activation_token}

      expect(response).to have_http_status(:success)
    end

    context "when user not found by the reset token" do
      it "returns not found" do
        get :activate, params: {organization_id: organization.id, id: "123"}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST currencies' do
    it 'returns http success' do
      post :set_currency, params: { organization_id: organization.id, user_id: user.id, currency: 'EUR' }
      expect(response).to have_http_status(:success)
    end

    it 'changes the user default currency' do
      post :set_currency, params: { organization_id: organization.id, user_id: user.id, currency: 'BRL' }
      currency = Users::Settings.find_by(user_id: user.id).currency
      expect(currency).to eq('BRL')
    end
  end
end
