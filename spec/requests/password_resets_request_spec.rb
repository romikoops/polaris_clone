# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PasswordResets", type: :request do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:admin_mailer_dummy) { instance_double("Notifications::UserMailer") }
  let(:client_mailer_dummy) { instance_double("Notifications::ClientMailer") }

  before do
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200, body: "", headers: {})
  end

  describe "POST /create" do
    shared_examples_for "initiating the password reset process" do
      it "returns http success" do
        post organization_password_resets_path(organization_id: organization.id), params: { email: user.email }

        expect(response).to have_http_status(:success)
      end

      it "returns not found" do
        post organization_password_resets_path(organization_id: organization.id), params: { email: nil }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is a Users::User" do
      let(:user) { FactoryBot.create(:users_user) }

      it_behaves_like "initiating the password reset process"
    end

    context "when user is a Users::Client" do
      it_behaves_like "initiating the password reset process"
    end
  end

  describe "GET /edit" do
    let(:redirect_url) { "http://localhost:8080/password_reset" }

    shared_examples_for "editing during the password reset process" do
      before do
        user.generate_reset_password_token!
        user.save
      end

      it "returns http success" do
        get edit_organization_password_reset_path(organization_id: organization.id, id: user.reset_password_token),
          params: { redirect_url: "http://localhost:8080/password_reset" }

        expect(subject).to redirect_to("#{redirect_url}?reset_password_token=#{user.reset_password_token}")
      end
    end

    context "when user is a Users::User" do
      let(:user) { FactoryBot.create(:users_user) }

      it_behaves_like "editing during the password reset process"
    end

    context "when user is a Users::Client" do
      it_behaves_like "editing during the password reset process"
    end
  end

  describe "PATCH /update" do
    shared_examples_for "finishing the password reset process" do
      before do
        user.generate_reset_password_token!
        user.save
      end

      it "returns http success" do
        patch organization_password_reset_path(organization_id: organization.id, id: user.reset_password_token),
          params: { password: "1234567890", password_confirmation: "1234567890" }

        expect(response).to have_http_status(:success)
      end

      it "returns not found" do
        patch organization_password_reset_path(organization_id: organization.id, id: "123")

        expect(response).to have_http_status(:unauthorized)
      end

      context "when password confirmation is a mismatch" do
        it "returns 422", skip: "Flaky Tests" do
          patch organization_password_reset_path(organization_id: organization.id, id: user.reset_password_token),
            params: { password: "123", password_confirmation: "1234" }

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when user is a Users::User" do
      let(:user) { FactoryBot.create(:users_user) }

      it_behaves_like "finishing the password reset process"
    end

    context "when user is a Users::Client" do
      it_behaves_like "finishing the password reset process"
    end
  end
end
