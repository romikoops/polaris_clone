# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Uploads", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:file_fixture) { File.read("spec/fixtures/files/dummy.json") }

  context "when v1" do
    let(:integration_token) { FactoryBot.create(:organizations_integration_token, organization: organization) }
    let(:Authorization) { "Bearer #{integration_token.token}" }

    path "/v1/uploads" do
      post "Create a new upload" do
        tags "Uploads (V1)"
        description "Create a new upload"
        operationId "createUpload"

        security [bearerAuth: []]
        consumes "application/json"
        produces "application/json"

        parameter name: :upload_params, in: :body, schema: {
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
          let(:upload_params) { { jsonData: file_fixture } }

          before do
            allow(Aws::S3::Client).to receive(:new).and_return(Aws::S3::Client.new(stub_responses: true))
            allow(Settings.aws).to receive(:ingest_bucket).and_return("itsmycargo-ingest")
          end

          run_test!
        end

        response "401", "Unauthorized request" do
          let(:Authorization) { "Basic deadbeef" }
          let(:upload_params) { nil }

          run_test!
        end

        response "400", "Bad request" do
          let(:upload_params) { nil }

          run_test!
        end
      end
    end
  end

  context "when v2" do
    let(:Authorization) { "Token token=FAKEKEY" }

    path "/v2/organizations/{organization_id}/uploads" do
      post "Create a new upload" do
        tags "Uploads (V2)"
        description "Create a new upload"
        operationId "createUpload"

        security [bearerAuth: []]
        consumes "application/json"
        produces "application/json"

        parameter name: :organization_id, in: :path, type: :string, description: "Organization ID"
        parameter name: :upload_params, in: :body, schema: {
          type: :object,
          properties: {
            file: {
              type: :string,
              description: "Provide the data as a downloadable url under the `file` parameter."
            }
          }
        }, required: true

        let(:upload_params) { { file: "https://deadbeef.nullisland.io/file.xlsx" } }
        let(:upload) { FactoryBot.build(:excel_data_services_upload) }
        let(:user) { FactoryBot.build(:users_user) }
        response "201", "Successful operation" do
          before do
            stub_request(:get, upload_params[:file]).to_return(status: 200, body: file_fixture)
            allow(ExcelDataServices::Upload).to receive(:new).and_return(upload)
            allow(Users::User).to receive(:find_by).with(email: "shopadmin@itsmycargo.com").and_return(user)
            allow(user).to receive(:id).and_return("user-id")
            allow(ExcelDataServices::UploaderJob).to receive(:perform_later)
          end

          run_test!
        end

        response "401", "Unauthorized request" do
          let(:Authorization) { "Token token=WRONG" }

          run_test!
        end
      end
    end

    path "/v2/organizations/{organization_id}/uploads/{id}" do
      let(:upload) { FactoryBot.create(:excel_data_services_upload) }

      get "Fetch Upload" do
        tags "Uploads (V2)"
        description "Fetch Upload"
        operationId "getQuery"

        security [bearerAuth: []]
        consumes "application/json"
        produces "application/json"

        parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
        parameter name: :id, in: :path, type: :string, description: "The Upload ID"

        let(:id) { upload.id }

        response "200", "successful operation" do
          run_test!
        end

        response "401", "Unauthorized request" do
          let(:Authorization) { "Token token=WRONG" }

          run_test!
        end
      end
    end
  end
end
