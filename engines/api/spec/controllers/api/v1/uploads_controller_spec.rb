# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::UploadsController, type: :controller do
    routes { Engine.routes }
    let(:uploaded_file) { fixture_file_upload("spec/fixtures/files/dummy.json", "application/json") }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:token) { FactoryBot.create(:organizations_integration_token, organization: organization) }

    before do
      Organizations.current_id = organization.id
      request.headers["Authorization"] = "Bearer #{token.token}"
    end

    describe "POST #create" do
      before do
        allow(ActionDispatch::Http::UploadedFile).to receive(:new).and_return(uploaded_file)
      end

      context "when token exists and is valid and the upload pipeline is successful" do
        it "renders 201" do
          post :create, params: { file: uploaded_file }

          expect(response.status).to eq(201)
        end
      end

      describe "Authentication" do
        shared_examples_for "an invalid request" do
          it "renders 401" do
            post :create, params: { file: uploaded_file }

            expect(response.status).to eq(401)
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

      describe "Trigger upload pipeline" do
        before do
          allow(Api::UploadPipelines::Base).to receive(:new).and_return(upload_pipeline)
          allow(upload_pipeline).to receive(:perform)
          allow(described_class::FileWrapper).to receive(:new).and_return(file_wrapper)
          allow(upload_pipeline).to receive(:message)
        end

        let(:upload_pipeline) { instance_double("Upload Pipeline") }

        context "when request content type is multipart/form-data" do
          let(:file_wrapper) { FactoryBot.build(:api_file_wrapper, content_type: "multipart/form-data") }

          it "builds the correct file wrapper" do
            post :create, params: { file: uploaded_file }

            expect(Api::UploadPipelines::Base).to have_received(:new).with(
              organization_id: token.organization_id,
              file_wrapper: file_wrapper
            )
          end
        end

        context "when request content type is application/json" do
          let(:json_data) { File.read("spec/fixtures/files/dummy.json") }
          let(:file_wrapper) { FactoryBot.build(:api_file_wrapper) }

          it "builds the correct file wrapper" do
            post :create, params: { json_data: json_data }, as: :json

            expect(Api::UploadPipelines::Base).to have_received(:new).with(
              organization_id: token.organization_id,
              file_wrapper: file_wrapper
            )
          end
        end
      end
    end
  end
end
