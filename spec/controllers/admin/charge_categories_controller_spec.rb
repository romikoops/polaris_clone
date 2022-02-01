# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ChargeCategoriesController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization, slug: "demo") }
  let(:user) { FactoryBot.create(:users_user) }
  let(:json_response) { JSON.parse(response.body) }

  before do
    FactoryBot.create(:users_membership, organization: organization, user: user)
    FactoryBot.create(:groups_group, :default, organization: organization)
    append_token_header
  end

  describe "POST #upload" do
    let(:perform_request) do
      post :upload, params: {
        "file" => Rack::Test::UploadedFile.new(File.expand_path("../../test_sheets/spec_sheet.xlsx", __dir__)),
        :organization_id => organization.id
      }
    end

    it_behaves_like "uploading request async"
  end

  describe "GET #download" do
    let(:expected_response) do
      {
        "key" => "charge_categories",
        "success_message" => "charge_categories sheet will be e-mailed to #{user.email}"
      }
    end

    it "returns the expected response data" do
      get :download, params: { organization_id: organization.id, options: { mot: "ocean" } }
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(response_data).to include(expected_response)
      end
    end
  end
end
