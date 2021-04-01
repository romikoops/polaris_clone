# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Uploads", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:token) { FactoryBot.create(:organizations_integration_token, organization: organization) }
  let(:Authorization) { "Bearer #{token.token}" }

  path "/v1/uploads" do
    post "Create a new upload" do
      tags "Upload"
      description "Create a new upload"
      operationId "createUpload"

      security [bearerAuth: []]
      consumes "multipart/form-data"
      produces "application/json"

      parameter name: :file, in: :formData, schema: {
        type: :object,
        properties: {
          file: {
            type: :string,
            format: :binary,
            description:
              "Provide the file to upload as form-data with form field `file`. Example cURL request:\n" \
              "```\n" \
              "curl --location --request POST 'https://api.itsmycargo.com/v1/uploads' \\\n" \
              "   --header 'Authorization: Bearer aa0c9a1d-7b50-4c14-ba8e-21a329877ddd' \\\n" \
              "   --form 'file=@\"/path/to/file.json\"'\n" \
              "```"
          }
        }
      }, required: true

      response "201", "Successful operation" do
        let(:file) { fixture_file_upload("spec/fixtures/files/dummy.json", "application/json") }

        before do
          allow(Aws::S3::Client).to receive(:new).and_return(Aws::S3::Client.new(stub_responses: true))
          allow(Settings.aws).to receive(:ingest_bucket).and_return("itsmycargo-ingest")
        end

        run_test!
      end

      response "401", "Unauthorized request" do
        let(:Authorization) { "Basic deadbeef" }
        let(:file) { nil }

        run_test!
      end

      response "400", "Bad request" do
        let(:file) { nil }

        run_test!
      end
    end
  end
end
