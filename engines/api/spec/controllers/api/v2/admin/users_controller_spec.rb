# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::Admin::UsersController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    shared_examples_for "unauthorized for non `Users::User`" do
      it "returns unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    shared_examples_for "user not found" do
      it "returns unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error code `user_not_found`" do
        expect(response_json["error_code"]).to eq("user_not_found")
      end
    end

    shared_examples_for "required fields are missing" do |missing_field|
      it "returns bad request" do
        expect(response).to have_http_status(:bad_request)
      end

      it "returns message with missing field name" do
        expect(response_json["message"]).to eq("param is missing or the value is empty: #{missing_field}")
      end
    end

    describe "POST #create" do
      let(:email) { "test@imc.com" }
      let(:profile) { { firstName: "John", lastName: "Doe" } }
      let(:settings) { { currency: "USD", locale: "en-US", language: "en-US" } }
      let(:create_params) { { email: email, profile: profile, settings: settings } }

      before { post :create, params: { organization_id: organization.id, admin: create_params }, as: :json }

      context "when trying to create an admin user as a `Users::Client`" do
        let(:user) { FactoryBot.create(:users_client) }

        it_behaves_like "unauthorized for non `Users::User`"
      end

      context "with valid params" do
        it "returns 201 created" do
          expect(response).to have_http_status(:created)
        end
      end

      context "with user settings params not a part of params" do
        let(:settings) { {} }

        it "returns 201 created" do
          expect(response).to have_http_status(:created)
        end
      end

      context "when email is blank" do
        let(:email) { "" }

        it_behaves_like "required fields are missing", "email"
      end

      context "when profile information is missing" do
        let(:profile) { {} }

        it_behaves_like "required fields are missing", "profile"
      end

      context "when one of the required files inside profile is missing" do
        let(:profile) { { firstName: "", lastName: "present" } }

        it_behaves_like "required fields are missing", "firstName"
      end

      context "when an user already exists" do
        before { post :create, params: { organization_id: organization.id, admin: create_params }, as: :json }

        it "returns unprocessable entity" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error code `duplicate_user_record`" do
          expect(response_json["error_code"]).to eq("duplicate_user_record")
        end
      end

      context "with invalid email format" do
        let(:email) { "invalid_email" }

        it "returns unprocessable entity" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "PATCH #update" do
      let(:email) { "changed@example.com" }
      let(:existing_user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
      let(:user_id) { existing_user.id }
      let(:profile) { { firstName: "John", lastName: "Doe" } }
      let(:update_params) { { email: email, profile: profile } }

      before { put :update, params: { organization_id: organization.id, id: user_id, admin: update_params }, as: :json }

      context "when trying to update an admin user as a `Users::Client`" do
        let(:user) { FactoryBot.create(:users_client) }

        it_behaves_like "unauthorized for non `Users::User`"
      end

      context "with valid params" do
        it "returns 200 updated" do
          expect(response).to have_http_status(:ok)
        end
      end

      context "when email is blank" do
        let(:email) { "" }

        it_behaves_like "required fields are missing", "email"
      end

      context "when profile information is missing" do
        let(:profile) { {} }

        it_behaves_like "required fields are missing", "profile"
      end

      context "when one of the required files inside profile is missing" do
        let(:profile) { { firstName: "", lastName: "present" } }

        it_behaves_like "required fields are missing", "firstName"
      end

      context "when user with the specified id does not exist" do
        let(:user_id) { "some random id" }

        it_behaves_like "user not found"
      end

      context "when trying to update an admin of a non member organization" do
        let(:user_id) do
          FactoryBot.create(:users_user, email: "different@imc.com").tap do |users_user|
            FactoryBot.create(:users_membership,
              organization: FactoryBot.create(:organizations_organization,
                slug: "different_org"), user: users_user)
          end.id
        end

        it_behaves_like "user not found"
      end
    end

    describe "DELETE #destroy" do
      let(:email) { "changed@example.com" }
      let(:existing_user) { FactoryBot.create(:users_user, email: email).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }

      before { delete :destroy, params: { organization_id: organization.id, id: existing_user.id }, as: :json }

      context "when trying to delete an admin user as a `Users::Client`" do
        let(:user) { FactoryBot.create(:users_client) }

        it_behaves_like "unauthorized for non `Users::User`"
      end

      context "with valid user id" do
        it "returns 200 successful" do
          expect(response).to have_http_status(:ok)
        end

        it "user with the existing_user's id cannot be searched" do
          expect(Users::User.find_by(email: email)).to be_nil
        end

        it "updates the `deleted_at` attribute for the existing user" do
          expect(Users::User.unscoped.find_by(email: email).deleted_at).to be_present
        end
      end

      context "with invalid user id" do
        let(:existing_user) { instance_double("Users::User", id: "random_id") }

        it_behaves_like "user not found"
      end

      context "when trying to destroy an admin of a non member organization" do
        let(:existing_user) do
          FactoryBot.create(:users_user, email: "different@imc.com").tap do |users_user|
            FactoryBot.create(:users_membership,
              organization: FactoryBot.create(:organizations_organization,
                slug: "different_org"), user: users_user)
          end
        end

        it_behaves_like "user not found"
      end
    end
  end
end
