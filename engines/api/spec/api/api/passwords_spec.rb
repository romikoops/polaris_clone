# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Passwords", type: :request, swagger: true do
  let(:reset_password_token) do
    user.save unless user.generate_reset_password_token!
    user.reload.reset_password_token
  end
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:Referer) { "http://siren-sir-1337.itsmycargo.dev" }

  before { FactoryBot.create(:organizations_domain, organization: organization, domain: "siren-%.itsmycargo.dev", default: false) }

  path "/v2/passwords/{reset_password_token}" do
    let(:user) { FactoryBot.create(:users_client, organization: organization, password: "OldPassword1") }

    patch "Reset password for the client's password token" do
      tags "Reset Password"
      description "Resets password for the specified client retrieved from the reset_password_token"
      operationId "reset_password"

      consumes "application/json"
      produces "application/json"

      parameter name: :reset_password_token, in: :path, type: :string, description: "one time reset_password_token generated for the client"
      parameter name: :password_reset_body, in: :body, schema: {
        type: :object,
        properties: {
          password: { type: :string, description: "new password of the client" },
          password_confirmation: { type: :string, description: "confirmation on the new password" }
        }
      }
      parameter name: :Referer, in: :header, type: :string, description: "HTTP Referrer from which the host/domain information will be extracted"

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
    let(:user) { FactoryBot.create(:users_client, organization: organization, password: "OldPassword1") }

    post "Request reset password email for an user" do
      tags "Reset Password"
      description "Request reset password email specified user email"
      operationId "reset_password"

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

  path "/v2/admin/passwords/{reset_password_token}" do
    let(:user) { FactoryBot.create(:users_user, password: "OldPassword1") }

    patch "Reset password for the Admin users password token" do
      tags "Reset Password"
      description "Resets password for the specified user retrieved from the reset_password_token"
      operationId "reset_password"

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

  path "/v2/admin/passwords/" do
    let(:user) { FactoryBot.create(:users_user, password: "OldPassword1") }

    post "Request reset password email for an user" do
      tags "Reset Password"
      description "Request reset password email specified user email"
      operationId "reset_password"

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
