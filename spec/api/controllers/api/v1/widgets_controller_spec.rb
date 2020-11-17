# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::WidgetsController, type: :controller do
    routes { Engine.routes }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user, email: "test@example.com") }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:response_error) { JSON.parse(response.body).dig("errors") }

    before do
      Organizations::Membership.create(user: user, organization: organization, role: "admin")
      request.headers["Authorization"] = token_header
    end

    describe "GET #index" do
      before do
        FactoryBot.create_list(:cms_data_widget, 5, organization: organization, data: "Test Widget Data")
      end

      it "returns the widgets for the organization specified" do
        get :index, params: {organization_id: organization.id}
        aggregate_failures do
          expect(response_data.first.dig("attributes", "data")).to eq("Test Widget Data")
        end
      end
    end

    shared_examples_for "an admin only action" do
      context "when user is not admin" do
        let(:user_2) { FactoryBot.create(:organizations_user, email: "test_user2@example.com", organization: organization) }
        let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user_2.id, scopes: "public") }

        it "halts the request and returns a forbidden response" do
          perform_request
          aggregate_failures do
            expect(response).to have_http_status(:forbidden)
          end
        end
      end
    end

    describe "POST #create" do
      let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "admin") }
      let(:widget_params) { FactoryBot.attributes_for(:cms_data_widget, data: "Test Data", order: 0) }
      let(:perform_request) { post :create, params: {widget: widget_params, organization_id: organization.id} }

      it_behaves_like "an admin only action"

      context "when request is successful" do
        it "creates the widgets and returns widgets for the organization" do
          perform_request
          aggregate_failures do
            expect(response_data.dig("attributes", "data")).to eq("Test Data")
            expect(response_data.dig("attributes", "order")).to eq(0)
          end
        end
      end

      context "when request is unsuccessful" do
        let(:widget_params) do
          FactoryBot.attributes_for(:cms_data_widget, data: "Test Data", order: nil)
        end

        it "doesnt create any widget and returns the correct error message" do
          perform_request
          aggregate_failures do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response_error.dig("order")).to include("can't be blank")
          end
        end
      end
    end

    describe "PATCH #update" do
      let(:widget) { FactoryBot.create(:cms_data_widget, organization: organization) }
      let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "admin") }
      let(:widget_params) { {name: "New widget name"} }
      let(:perform_request) { patch :update, params: {id: widget.id, widget: widget_params, organization_id: organization.id} }

      it_behaves_like "an admin only action"

      context "when request is successful" do
        it "updates the widget and returns a 200 on success" do
          perform_request
          aggregate_failures do
            expect(response).to be_successful
            expect(CmsData::Widget.find(widget.id).name).to eq("New widget name")
          end
        end
      end

      context "when request is unsuccessful" do
        let(:widget_params) { {name: nil} }

        it "returns the update errors with a 422 status" do
          perform_request
          aggregate_failures do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response_error.dig("name")).to include("can't be blank")
          end
        end
      end
    end

    describe "DELETE #destroy" do
      let(:widget) { FactoryBot.create(:cms_data_widget, organization: organization, name: "Deleted Widget") }
      let(:perform_request) { delete :destroy, params: {id: widget.id, organization_id: organization.id} }

      it_behaves_like "an admin only action"

      it "deletes the widget and returns a 204" do
        perform_request
        aggregate_failures do
          expect(response).to have_http_status(:no_content)
          expect(CmsData::Widget.exists?(name: "Deleted Widget")).to be false
        end
      end

      context "when widget does not exist" do
        let(:widget) { FactoryBot.create(:cms_data_widget, organization: organization) }

        before { widget.destroy }

        it "returns a 404" do
          perform_request
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
