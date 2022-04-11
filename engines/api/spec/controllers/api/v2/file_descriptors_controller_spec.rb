# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::FileDescriptorsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = "Token token=FAKEKEY"
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }

    describe "POST #create" do
      let(:file_path) { "/testing/download/sailing_schedule/test.png" }
      let(:file_created_at) { 2.days.ago.to_s }
      let(:created_file_descriptor) { FileDescriptor.find_by(file_path: file_path) }
      let(:params) do
        {
          fileDescriptor: {
            organizationSlug: organization.slug,
            filePath: file_path,
            fileType: "schedule",
            originator: "SFTP",
            source: "itsmycargo_databucket",
            sourceType: "S3_BUCKET",
            fileCreatedAt: file_created_at,
            fileUpdatedAt: 2.days.ago.to_s,
            syncedAt: 1.day.ago.to_s
          }
        }
      end

      let(:successful_response_data) do
        {
          "id" => created_file_descriptor.id,
          "type" => "fileDescriptor",
          "attributes" => {
            "organizationId" => organization.id,
            "filePath" => file_path,
            "fileType" => "schedule",
            "originator" => "SFTP",
            "source" => "itsmycargo_databucket",
            "sourceType" => "S3_BUCKET",
            "status" => "ready",
            "fileCreatedAt" => created_file_descriptor.file_created_at,
            "fileUpdatedAt" => created_file_descriptor.file_updated_at,
            "syncedAt" => created_file_descriptor.synced_at
          }
        }
      end

      shared_examples_for "a successful create" do
        before { post :create, params: params }

        it "returns a 201 response" do
          expect(response).to have_http_status(:created)
        end

        it "returns files descriptor attributes after successful creation" do
          expect(response_data).to include(successful_response_data)
        end
      end

      it_behaves_like "a successful create"

      context "when one of the required params are not present" do
        let(:file_path) { nil }

        before { post :create, params: params }

        it "returns 400 bad request" do
          expect(response).to have_http_status(:bad_request)
        end
      end

      context "when one of the date field is specified with invalid date format" do
        let(:file_created_at) { "12/10/2020" }

        before { post :create, params: params }

        it "returns 422 bad request" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when none of the date fields are specified" do
        let(:params) do
          {
            fileDescriptor: {
              organizationSlug: organization.slug,
              filePath: file_path,
              fileType: "schedule",
              originator: "SFTP",
              source: "itsmycargo_databucket",
              sourceType: "S3_BUCKET"
            }
          }
        end

        it_behaves_like "a successful create"
      end
    end
  end
end
