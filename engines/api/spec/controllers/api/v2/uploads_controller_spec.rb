# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::UploadsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = "Token token=FAKEKEY"
      FactoryBot.create(:users_user, email: "shopadmin@itsmycargo.com")
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:params) do
      {
        organization_id: organization.id,
        file: signed_url
      }
    end

    describe "POST #create" do
      context "when file is present" do
        let(:signed_url) { "https://deadbeef.nullisland.io/file.xlsx" }
        let(:file_fixture) { File.read("spec/fixtures/files/dummy.json") }

        before do
          stub_request(:get, signed_url).to_return(status: 200, body: file_fixture)
          allow(ExcelDataServices::UploaderJob).to receive(:perform_later)
        end

        it "successfuly triggers the upload", :aggregate_failures do
          post :create, params: params, as: :json
          expect(response.status).to eq(201)
          expect(ExcelDataServices::UploaderJob).to have_received(:perform_later)
        end
      end

      context "when file is not present" do
        let(:signed_url) { nil }

        it "returns 422" do
          post :create, params: params, as: :json
          expect(response.status).to eq(400)
        end
      end
    end
  end
end
