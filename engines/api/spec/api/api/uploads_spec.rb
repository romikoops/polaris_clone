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
      consumes "application/json"
      produces "application/json"

      parameter name: :upload, in: :body, schema: {
        type: :object,
        properties: {
          jsonData: {
            type: :string,
            description:
              "Provide the data to upload as `application/json`. " \
              "Serialize the payload as a value for the key `jsonData` (case invariant). " \
              "Example cURL request:\n" \
              "```\n" \
              "curl --location --request POST 'https://api.itsmycargo.com/v1/uploads' \\\n" \
              "   --header 'Authorization: Bearer aa0c9a1d-7b50-4c14-ba8e-21a329877ddd' \\\n" \
              "   --header 'Content-Type: application/json' \\\n" \
              "   --data-raw '\{\n" \
              "   \"jsonData\": \"\{\\\"foo\\\":123\}\"\n" \
              "   \}'\n" \
              "```"
          }
        }
      }, required: true

      response "201", "Successful operation" do
        let(:upload) { { jsonData: File.read("spec/fixtures/files/dummy.json") } }

        before do
          allow(Aws::S3::Client).to receive(:new).and_return(Aws::S3::Client.new(stub_responses: true))
          allow(Settings.aws).to receive(:ingest_bucket).and_return("itsmycargo-ingest")
        end

        run_test!
      end

      response "401", "Unauthorized request" do
        let(:Authorization) { "Basic deadbeef" }
        let(:upload) { nil }

        run_test!
      end

      response "400", "Bad request" do
        let(:upload) { nil }

        run_test!
      end
    end
  end
end
