# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::PasswordsController, type: :controller do
    routes { Engine.routes }

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_client, organization: organization, password: "OldPassword1") }

    before { FactoryBot.create(:organizations_domain, organization: organization, domain: "test.itsmycargo.com", default: false) }

    describe "#update" do
      subject(:reset_password) do
        request.headers["Referer"] = "http://test.itsmycargo.com"
        patch :update, params: {
          id: refresh_token,
          password: password,
          password_confirmation: password_confirmation
        }, as: :json
      end

      let(:refresh_token) { user.reset_password_token }
      let(:password) { "Hardpassword1993" }
      let(:password_confirmation) { password }

      before do
        user.generate_reset_password_token!
        user.save
      end

      context "with valid password, password confirmation and strong password" do
        before { reset_password }

        it "resets the password successfully" do
          expect(user.reload.valid_password?(password)).to be true
        end

        it "returns a 200 success response" do
          expect(response).to have_http_status(:success)
        end
      end

      context "when password field is not specified" do
        let(:password) { nil }

        it "retrurns bad request" do
          reset_password
          expect(response).to have_http_status(:bad_request)
        end
      end

      context "when password field does not match password confirmation" do
        let(:password_confirmation) { "mismatch" }

        it "returns http status as unprocessable_entity" do
          reset_password
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when password is less than 8 characters" do
        let(:password) { "12345ab" }

        it "returns http status as unprocessable_entity" do
          reset_password
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "#create" do
      context "when user with the specified email is exists" do
        it "returns a 200 OK response" do
          request.headers["Referer"] = "http://test.itsmycargo.com"
          post :create, params: { email: user.email }, as: :json
          expect(response).to have_http_status(:ok)
        end

        it "triggers the mailer job" do
          request.headers["Referer"] = "http://test.itsmycargo.com"
          expect { post :create, params: { email: user.email }, as: :json }.to have_enqueued_job
        end
      end

      context "when the user originates from SSO" do
        let(:user) { FactoryBot.create(:users_client, organization: organization, password: nil) }

        it "fails with 401 unauthorized" do
          request.headers["Referer"] = "http://test.itsmycargo.com"
          post :create, params: { email: user.email }, as: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when the user is not found" do
        it "fails with 401 unauthorized" do
          request.headers["Referer"] = "http://test.itsmycargo.com"
          post :create, params: { email: "notauser@itsmycargo.test" }, as: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when referer header is not passed as header" do
        it "fails with 404 not found" do
          post :create, params: { email: user.email }, as: :json
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when referer is not whitelisted" do
        it "fails with 404 not found" do
          request.headers["Referer"] = "http://example.domain.com"
          post :create, params: { email: user.email }, as: :json
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when referer is not in valid format" do
        it "fails with 404 not found" do
          request.headers["Referer"] = "test.itsmycargo.com"
          post :create, params: { email: user.email }, as: :json
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
