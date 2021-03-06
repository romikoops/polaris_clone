# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController do
  let(:addresses) { FactoryBot.create_list(:address, 5) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:domain) { organization.domains.default }

  before do
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200, body: "", headers: {})

    request.env["HTTP_REFERER"] = "http://#{domain.domain}"
    Organizations.current_id = organization.id
    append_token_header
    addresses.each do |address|
      FactoryBot.create(:legacy_user_address, user_id: user.id, address: address)
    end
  end

  describe "GET #home" do
    it "returns an http status of success" do
      get :home, params: { organization_id: user.organization_id, user_id: user.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns an http status of success", :aggregate_failures do
      get :show, params: { organization_id: user.organization_id, user_id: user.id }
      expect(json.dig(:data, :id)).to eq(user.id)
      expect(json.dig(:data, :inactivityLimit)).to eq(86_400)
    end
  end

  describe "POST #create" do
    let(:test_email) { "test@itsmycargo.com" }
    let(:created_user) { Users::Client.find_by(email: test_email, organization: organization) }
    let(:return_token) { Doorkeeper::AccessToken.find_by(token: json.dig(:data, :access_token)) }
    let(:params) do
      {
        user: user_param
      }
    end
    let(:user_param) do
      {
        email: test_email,
        password: "123456789",
        organization_id: user.organization_id,
        company_name: "Person Freight",
        first_name: "Test",
        last_name: "Person",
        phone: "01628710344"
      }
    end

    before { FactoryBot.create(:companies_company, organization: organization, name: "default") }

    it "creates a new user", :aggregate_failures do
      post :create, params: params
      expect(created_user.profile.first_name).to eq("Test")
      expect(return_token.application.name).to eq("dipper")
    end

    context "when creating with no profile attributes" do
      let(:user_param) do
        {
          email: test_email,
          password: "123456789",
          organization_id: user.organization_id
        }
      end

      it "returns http status and updates the user" do
        post :create, params: params
        expect(Users::ClientProfile).to exist(user: created_user)
      end
    end

    context "when creating with wrong params" do
      let(:user_param) do
        {
          email: nil,
          password: "123456789",
          organization_id: user.organization_id
        }
      end

      it "has the status UnprocessableEntity" do
        post :create, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when creating with an existing users email" do
      let(:user_param) do
        {
          email: user.email,
          password: "123456789",
          organization_id: user.organization_id
        }
      end

      it "has the status UnprocessableEntity" do
        post :create, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when creating with an existing users email but rails validations miss" do
      let(:user_param) do
        {
          email: user.email,
          password: "123456789",
          organization_id: user.organization_id
        }
      end

      before do
        client_creator = instance_double(Api::ClientCreationService)
        allow(Api::ClientCreationService).to receive(:new).and_return(client_creator)
        allow(client_creator).to receive(:perform).and_raise(ActiveRecord::RecordNotUnique)
      end

      it "has the status UnprocessableEntity" do
        post :create, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the shop prohibits user registration" do
      before do
        allow(controller).to receive(:current_scope).and_return({ closed_registration: true })
      end

      it "has the status Unauthorized", :aggregate_failures do
        post :create, params: params

        expect(response).to have_http_status(:unauthorized)
        expect(json[:error_code]).to eq("user_registration_not_allowed")
      end
    end
  end

  describe "POST #passwordless_authentication" do
    before do
      organization.scope.update(content: { "signup_form_fields" => { "password" => false } })
    end

    let(:params) do
      {
        user: user_param
      }
    end

    context "when user does not exist" do
      let(:test_email) { "test_new@itsmycargo.com" }
      let(:user_param) do
        {
          email: test_email,
          organization_id: user.organization_id,
          phone: "01628710344"
        }
      end

      it "creates a new user without password" do
        post :passwordless_authentication, params: params

        aggregate_failures do
          expect(json[:data][:access_token]).to be_present
          expect(Users::Client.find_by(email: test_email)).to be_present
        end
      end
    end

    context "when user already exists" do
      let(:user_param) do
        {
          email: user.email,
          organization_id: user.organization_id,
          phone: "01628710344"
        }
      end

      it "returns a new token for the existing user" do
        post :passwordless_authentication, params: params

        expect(json[:data][:access_token]).to be_present
      end
    end

    context "when password is required" do
      before do
        organization.scope.update(content: { "signup_form_fields" => { "password" => true } })
      end

      let(:user_param) do
        {
          email: user.email,
          organization_id: user.organization_id,
          phone: "01628710344"
        }
      end

      it "returns 401 - unauthorized" do
        post :passwordless_authentication, params: params

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when no email provided" do
      let(:user_param) do
        {
          email: nil,
          organization_id: user.organization_id,
          phone: "01628710344"
        }
      end

      it "returns 422 - unprocessable_entity" do
        post :passwordless_authentication, params: params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST #update" do
    let(:return_token) { Doorkeeper::AccessToken.find_by(token: json.dig(:data, :headers, :access_token)) }
    let(:params) do
      {
        organization_id: user.organization_id,
        user_id: user.id,
        update: {
          company_name: "Person Freight",
          company_number: "Person Freight",
          email: "test+123@itsmycargo.com",
          first_name: "Test",
          guest: false,
          last_name: "Person",
          phone: "01628710344",
          organization_id: user.organization_id
        }
      }
    end

    it "returns http success, updates the user and send the email", :aggregate_failures do
      post :update, params: params
      expect(user.profile.reload.first_name).to eq("Test")
      expect(return_token.application.name).to eq("dipper")
      expect(response).to have_http_status(:success)
    end

    context "when updating with no profile attributes" do
      let(:params) do
        {
          organization_id: user.organization_id,
          user_id: user.id,
          update: {
            guest: true
          }
        }
      end

      it "returns http status and updates the user" do
        post :update, params: params
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /activate" do
    it "returns http success" do
      user.setup_activation
      user.save

      get :activate, params: { organization_id: organization.id, id: user.activation_token }

      expect(response).to have_http_status(:success)
    end

    context "when user not found by the reset token" do
      it "returns not found" do
        get :activate, params: { organization_id: organization.id, id: "123" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST currencies" do
    it "returns http success" do
      post :set_currency, params: { organization_id: organization.id, user_id: user.id, currency: "EUR" }
      expect(response).to have_http_status(:success)
    end

    it "changes the user default currency" do
      post :set_currency, params: { organization_id: organization.id, user_id: user.id, currency: "BRL" }
      currency = Users::ClientSettings.find_by(user_id: user.id).currency
      expect(currency).to eq("BRL")
    end
  end
end
