# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Passwords", type: :request, swagger: true do
  let(:reset_password_token) do
    user.generate_reset_password_token!
    user.reload.reset_password_token
  end

  let(:user) { FactoryBot.create(:users_user, password: "OldPassword1") }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v2/passwords/{reset_password_token}" do
    patch "Reset password for the users password token" do
      tags "Reset Password"
      description "Resets password for the specified user retrieved from the reset_password_token"
      operationId "reset_password"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :reset_password_token, in: :path, type: :string, description: "one time reset_password_token generated for the User"
      parameter name: :password_reset_body, in: :body, schema: {
        type: :object,
        properties: {
          password: { type: :string, description: "new password of the user" },
          password_confirmation: { type: :string, description: "confirmation on the new password" }
        }
      }

      let(:password) { "Hardpassword1993" }

      response "200", "successful operation" do
        let(:password_reset_body) { { password: password, password_confirmation: password } }
        schema type: :object,
               properties: {
                 success: {
                   type: :boolean
                 }
               }
        run_test!
      end

      response "422", "Unprocessable Entity" do
        let(:password_reset_body) { { password: password, password_confirmation: "mismatch" } }
        schema type: :object,
               properties: {
                 error_code: {
                   type: :string,
                   description: "describes password errors which is either `password_mismatch` or `weak_password`"
                 }
               }
        run_test!
      end
    end
  end

  path "/v2/passwords/" do
    post "Request reset password email for an user" do
      tags "Reset Password"
      description "Request reset password email specified user email"
      operationId "reset_password"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :request_password_reset_body, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, description: "email id of the user for resetting password" }
        }
      }

      parameter name: :Referer, in: :header, type: :string, description: "HTTP Referrer from which the host/domain information will be extracted"

      response "200", "successful operation" do
        let(:request_password_reset_body) { { email: user.email } }
        let(:Referer) { "http://siren-sir-1337.itsmycargo.dev" }

        schema type: :object,
               properties: {
                 success: {
                   type: :boolean
                 }
               }
        run_test!
      end

      response "401", "Unauthorized" do
        let(:request_password_reset_body) { { email: "missing@itsmycargo.com" } }
        let(:Referer) { "" }
        schema type: :object,
               properties: {
                 error_code: {
                   type: :string,
                   description: "describes unauthorized error reason with error codes `user_not_available`, `sso_user_not_supported`, invalid_or_empty_referer"
                 }
               }
        run_test!
      end
    end
  end
end
