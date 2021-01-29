# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::LocalChargesController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization, slug: "demo") }
  let(:user) { FactoryBot.create(:users_user) }

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    append_token_header
  end

  describe "GET #index" do
    before do
      FactoryBot.create(:legacy_local_charge,
        organization: organization,
        effective_date: Date.parse("Thu, 24 Jan 2019"),
        expiration_date: Date.parse("Fri, 24 Jan 2020"))
    end

    it "returns an http status of success" do
      get :index, params: {organization_id: organization.id}
      expect(response).to have_http_status(:success)
    end

    it "returns the correct data given the params" do
      get :index, params: {organization_id: organization.id, per_page: 10, name_desc: "true"}
      json_response = JSON.parse(response.body)
      expect(json_response.dig("data", "localChargeData", 0, "id")).to eq(::Legacy::LocalCharge.first.id)
    end
  end

  describe "POST #edit" do
    let(:local_charge) do
      FactoryBot.create(:legacy_local_charge,
        organization: organization,
        effective_date: Date.parse("Thu, 24 Jan 2019"),
        expiration_date: Date.parse("Fri, 24 Jan 2020"))
    end
    let(:fees) { {"ABC" => 123} }

    it "edits the fees correctly" do
      post :edit, params: {
        organization_id: organization.id, id: local_charge.id, data: {id: local_charge.id, fees: fees}
      }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(local_charge.reload.fees.values.first.to_i).to eq(fees.values.first)
      end
    end
  end

  describe "POST #upload" do
    let(:perform_request) {
      post :upload, params: {
        "file" => Rack::Test::UploadedFile.new(File.expand_path("../../test_sheets/spec_sheet.xlsx", __dir__)),
        :organization_id => organization.id
      }
    }

    context "with errors" do
      let(:errors_arr) do
        [{row_no: 1, reason: "A"},
          {row_no: 2, reason: "B"},
          {row_no: 3, reason: "C"},
          {row_no: 4, reason: "D"}]
      end
      let(:error) { {has_errors: true, errors: errors_arr} }

      let(:complete_email_job) { performed_jobs.find { |j| j[:args][0] == "UploadMailer" } }
      let(:resulted_errors) {
        complete_email_job[:args][3]["result"]["errors"].map { |err| err.except("_aj_symbol_keys") }
      }

      before do
        excel_service = instance_double("ExcelDataServices::Loaders::Uploader")
        allow(ExcelDataServices::Loaders::Uploader).to receive(:new).and_return(excel_service)
        allow(excel_service).to receive(:perform).and_return(error)

        allow(controller).to receive(:current_organization).and_return(organization)
      end

      it_behaves_like "uploading request async"

      it "sends an email with the upload errors" do
        perform_enqueued_jobs do
          perform_request
        end

        expect(resulted_errors).not_to be_empty
      end
    end
  end

  describe "GET #download" do
    let(:hubs) do
      [
        FactoryBot.create(:hub,
          organization: organization,
          name: "Gothenburg",
          hub_type: "ocean",
          nexus: FactoryBot.create(:nexus, name: "Gothenburg")),
        FactoryBot.create(:hub,
          organization: organization,
          name: "Shanghai",
          hub_type: "ocean",
          nexus: FactoryBot.create(:nexus, name: "Shanghai"))
      ]
    end
    let(:organization_vehicle) do
      FactoryBot.create(:tenant_vehicle, organization: organization)
    end

    before do
      FactoryBot.create(
        :local_charge,
        mode_of_transport: "ocean",
        load_type: "lcl",
        hub: hubs.first,
        organization: organization,
        tenant_vehicle: organization_vehicle,
        counterpart_hub_id: hubs.second,
        direction: "export",
        fees: {
          "DOC" => {
            "key" => "DOC", "max" => nil, "min" => nil, "name" => "Documentation",
            "value" => 20, "currency" => "EUR", "rate_basis" => "PER_BILL"
          }
        },
        dangerous: nil,
        effective_date: Date.parse("Thu, 24 Jan 2019"),
        expiration_date: Date.parse("Fri, 24 Jan 2020"),
        user_id: nil
      )
    end

    it "returns error with messages when an error is raised" do
      get :download, params: {organization_id: organization.id, options: {mot: nil, group_id: nil}}
      json_response = JSON.parse(response.body)
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response.dig("data", "url")).to include("demo__local_charges_.xlsx")
      end
    end
  end

  describe "DELETE #destroy" do
    let(:local_charge) do
      FactoryBot.create(:legacy_local_charge,
        organization: organization,
        effective_date: Date.parse("Thu, 24 Jan 2019"),
        expiration_date: Date.parse("Fri, 24 Jan 2020"))
    end

    it "returns an http status of success" do
      delete :destroy, params: {organization_id: organization, id: local_charge.id}
      expect(response).to have_http_status(:success)
    end

    it "removes the local_charge" do
      delete :destroy, params: {organization_id: organization, id: local_charge.id}
      expect(::Legacy::LocalCharge.find_by(id: local_charge.id)).to be(nil)
    end
  end
end
