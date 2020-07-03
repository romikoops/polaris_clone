require "rails_helper"

RSpec.describe "PasswordResets", type: :request do
  let(:organization) { create(:organizations_organization) }
  let(:user) { create(:authentication_user, organization_id: organization.id) }

  before do
    create(:organizations_theme, organization: organization)
  end

  describe "POST /create" do
    it "returns http success" do
      post organization_password_resets_path(organization_id: organization.id), params: {email: user.email}

      expect(response).to have_http_status(:success)
    end

    context "when user not found by email" do
      it "returns not found" do
        post organization_password_resets_path(organization_id: organization.id), params: {email: nil}

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /edit" do
    let(:redirect_url) { "http://localhost:8080/password_reset" }

    it "returns http success" do
      user.generate_reset_password_token!

      get edit_organization_password_reset_path(organization_id: organization.id, id: user.reset_password_token),
        params: {redirect_url: "http://localhost:8080/password_reset"}

      expect(subject).to redirect_to("#{redirect_url}?reset_password_token=#{user.reset_password_token}")
    end

    context "when user not found by the reset token" do
      it "returns not found" do
        get edit_organization_password_reset_path(organization_id: organization.id, id: "123")

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /update" do
    it "returns http success" do
      user.generate_reset_password_token!

      patch organization_password_reset_path(organization_id: organization.id, id: user.reset_password_token)

      expect(response).to have_http_status(:success)
    end

    context "when user not found by the reset token" do
      it "returns not found" do
        patch organization_password_reset_path(organization_id: organization.id, id: "123")

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when password confirmation is a mismatch" do
      it "returns 422" do
        user.generate_reset_password_token!
        patch organization_password_reset_path(organization_id: organization.id, id: user.reset_password_token),
          params: {password: "123", password_confirmation: "1234"}

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
