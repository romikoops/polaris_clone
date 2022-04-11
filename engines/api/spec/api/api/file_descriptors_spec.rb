# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "FileDescriptors", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:Authorization) { "Token token=FAKEKEY" }

  path "/v2/file_descriptors" do
    let(:file_created_at) { 2.days.ago.to_s }

    post "Create a Request" do
      tags "FileDescriptor"
      description "Creates a File::FileDescriptor with the provided information"
      operationId "createFileDescriptor"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :file_descriptor_params, in: :body, schema: {
        type: :object,
        properties: {
          filePath: { type: :string, description: "File path description of a file with its name." },
          fileType: { type: :string, description: "File identifier matching the uploaders." },
          originator: { type: :string, description: "Datasource  of the file ex: 'SFTP'." },
          source: { type: :string, description: "Current address of the file ex: s3 bucket url link." },
          sourceType: { type: :string, description: "source identifier ex: S3_BUCKET" },
          organizationSlug: { type: :string, description: "Organization to which the file belong to." },
          fileCreatedAt: { type: :string, description: "The created date and time of the file even before it was synced." },
          fileUpdatedAt: { type: :string, description: "File updated at date and time in its originator." },
          syncedAt: { type: :string, description: "Date and time when the file was synced to the source." }

        }
      }

      let(:file_descriptor_params) do
        {
          fileDescriptor: {
            organizationSlug: organization.slug,
            filePath: "/testing/download/sailing_schedule/test.png",
            fileType: "schedule",
            originator: "SFTP",
            source: "itsmycargo_dataflow",
            sourceType: "S3_BUCKET",
            fileCreatedAt: file_created_at,
            fileUpdatedAt: 2.days.ago.to_s,
            syncedAt: 1.day.ago.to_s
          }
        }
      end

      response "201", "Successful operation" do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                attributes: { "$ref" => "#/components/schemas/file_descriptor" }
              }
            }
          },
          required: ["data"]

        run_test!
      end

      response "400", "Bad Request" do
        let(:file_descriptor_params) { {} }

        run_test!
      end

      response "422", "unprocessable entity" do
        let(:file_created_at) { "invalid_date" }

        run_test!
      end
    end
  end
end
