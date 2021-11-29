# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::PasswordsController, type: :controller do
    routes { Engine.routes }

    let(:user) { FactoryBot.create(:users_user) }

    describe "#update" do
      subject(:reset_password) do
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
  end
end
