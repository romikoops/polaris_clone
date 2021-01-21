# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::UploadsController, type: :controller do
    routes { Engine.routes }
    let(:file) { fixture_file_upload("spec/fixtures/files/dummy.json", "application/json") }

    before do
      request.headers["Authorization"] = token.token
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:token) { FactoryBot.create(:organizations_integration_token, organization: organization) }

    describe "POST #upload" do
      let(:client) { Aws::S3::Client.new(stub_responses: true) }
      let(:expected_response) {
        {bucket: Settings.aws.ingest_bucket,
         key: "#{organization.id}/okargo_#{file.original_filename}",
         body: "{\n  \"test\": \"test\"\n}\n",
         content_type: "application/json"}
      }

      before do
        allow(Aws::S3::Client).to receive(:new).and_return(client)
        allow(Settings.aws).to receive(:ingest_bucket).and_return("itsmycargo-ingest")
      end

      describe "Authentication" do
        context "when token exists and valid" do
          it "renders 200" do
            post :create, params: {file: file}, as: :json

            expect(response).to be_successful
          end

          it "makes an upload request" do
            post :create, params: {file: file}, as: :json

            expect(client.api_requests.count).to eq 1
            expect(client.api_requests.first[:params]).to eq expected_response
          end
        end

        context "when token scope is not permitted" do
          let(:token) {
            FactoryBot.create(:organizations_integration_token, scope: "pricings.download", organization: organization)
          }

          it "renders 401" do
            post :create, params: {file: file}, as: :json

            expect(response.status).to eq 401
          end

          it "doesn't upload" do
            post :create, params: {file: file}, as: :json

            expect(client.api_requests.count).to eq 0
          end
        end

        context "when token is expired" do
          let(:token) {
            FactoryBot.create(:organizations_integration_token, expires_at: Date.yesterday, organization: organization)
          }

          it "renders 401" do
            post :create, params: {file: file}, as: :json

            expect(response.status).to eq 401
          end

          it "doesn't upload" do
            post :create, params: {file: file}, as: :json

            expect(client.api_requests.count).to eq 0
          end
        end

        context "when token is not found" do
          let(:token) { FactoryBot.build(:organizations_integration_token) }

          it "renders 401" do
            post :create, params: {file: file}, as: :json

            expect(response.status).to eq 401
          end

          it "doesn't upload" do
            post :create, params: {file: file}, as: :json

            expect(client.api_requests.count).to eq 0
          end
        end
      end

      describe "upload" do
        context "when file format is json" do
          it "uploads successfully" do
            post :create, params: {file: file}, as: :json

            expect(client.api_requests.count).to eq 1
            expect(client.api_requests.first[:params]).to eq expected_response
          end
        end

        context "when upload fails" do
          before do
            client.stub_responses(
              :put_object, ->(context) {
                "NoSuchBucket"
              }
            )
          end

          it "renders error" do
            post :create, params: {file: file}, as: :json

            expect(response.status).to eq 422
          end
        end

        context "when etag is not present" do
          before do
            client.stub_responses(
              :put_object, ->(context) {
                {etag: nil}
              }
            )
          end

          it "renders error" do
            post :create, params: {file: file}, as: :json

            expect(response.status).to eq 422
          end
        end
      end
    end
  end
end
