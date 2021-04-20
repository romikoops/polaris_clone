# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::UploadsController, type: :controller do
    routes { Engine.routes }
    let(:uploaded_file) { fixture_file_upload("spec/fixtures/files/dummy.json", "application/json") }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:token) { FactoryBot.create(:organizations_integration_token, organization: organization) }

    before do
      request.headers["Authorization"] = "Bearer #{token.token}"
    end

    describe "POST #upload" do
      let(:client) { Aws::S3::Client.new(stub_responses: true) }
      let(:expected_request) do
        {
          bucket: Settings.aws.ingest_bucket,
          content_type: upload_content_type,
          key: "#{organization.id}/#{upload_filename}",
          body: upload_body
        }
      end
      let(:upload_content_type) { uploaded_file.content_type }
      let(:upload_filename) { uploaded_file.original_filename }
      let(:upload_body) { uploaded_file.tempfile }

      before do
        allow(Aws::S3::Client).to receive(:new).and_return(client)
        allow(Settings.aws).to receive(:ingest_bucket).and_return("itsmycargo-ingest")
        allow(ActionDispatch::Http::UploadedFile).to receive(:new).and_return(uploaded_file)
      end

      describe "Authentication" do
        shared_examples_for "an invalid request" do
          it "renders 401" do
            post :create, params: { file: uploaded_file }

            expect(response.status).to eq(401)
          end

          it "doesn't upload" do
            post :create, params: { file: uploaded_file }

            expect(client.api_requests.count).to eq(0)
          end
        end

        context "when token exists and valid" do
          it "renders 201" do
            post :create, params: { file: uploaded_file }

            expect(response.status).to eq(201)
          end
        end

        context "when token scope is not permitted" do
          let(:token) do
            FactoryBot.create(:organizations_integration_token, scope: "pricings.download", organization: organization)
          end

          it_behaves_like "an invalid request"
        end

        context "when token is expired" do
          let(:token) do
            FactoryBot.create(:organizations_integration_token, expires_at: Date.yesterday, organization: organization)
          end

          it_behaves_like "an invalid request"
        end

        context "when token is not found" do
          let(:token) do
            FactoryBot.build(:organizations_integration_token)
          end

          it_behaves_like "an invalid request"
        end
      end

      describe "upload" do
        context "when request content type is multipart/form-data" do
          it "builds the correct upload request" do
            post :create, params: { file: uploaded_file }

            expect(client.api_requests.first[:params]).to eq(expected_request)
          end
        end

        context "when request content type is application/json" do
          let(:json_data) { File.read("spec/fixtures/files/dummy.json") }
          let(:upload_content_type) { "application/json" }
          let(:upload_filename) { "unknown at request time (gets generated)" }
          let(:upload_body) { json_data }

          it "builds the correct upload request" do
            post :create, params: { json_data: json_data }, as: :json

            expect(client.api_requests.first[:params].except(:key)).to eq(expected_request.except(:key))
          end
        end

        context "when upload fails" do
          before do
            client.stub_responses(
              :put_object, ->(_) { "NoSuchBucket" }
            )
          end

          it "renders error" do
            post :create, params: { file: uploaded_file }

            expect(response.status).to eq(422)
          end
        end

        context "when etag is not present" do
          before do
            client.stub_responses(
              :put_object, ->(_) { { etag: nil } }
            )
          end

          it "renders error" do
            post :create, params: { file: uploaded_file }

            expect(response.status).to eq(422)
          end
        end
      end
    end
  end
end
