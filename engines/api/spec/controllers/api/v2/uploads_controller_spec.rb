# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::UploadsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = "Token token=FAKEKEY"
    end

    let(:xlsx) { File.open(file_fixture("excel/example_trucking.xlsx").to_s) }
    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:params) {
      {
        organization_id: organization.id,
        file: signed_url
      }
    }

    before { FactoryBot.create(:users_user, email: "shopadmin@itsmycargo.com") }

    describe "POST #create" do
      context "when file is present" do
        let(:signed_url) { "FAKE_SIGNED_URL" }
        before do
          allow(URI).to receive(:parse).and_return(double(open: xlsx))
          allow(ExcelDataServices::UploaderJob).to receive(:perform_later)
        end

        it "successfuly triggers the upload", :aggregate_failures do
          post :create, params: params, as: :json
          expect(response.status).to eq(200)
          expect(ExcelDataServices::UploaderJob).to have_received(:perform_later)
        end
      end

      context "when file is present" do
        let(:signed_url) { nil }

        it "returns 422 without a file url" do
          post :create, params: params, as: :json
          expect(response.status).to eq(400)
        end
      end
    end
  end
end
