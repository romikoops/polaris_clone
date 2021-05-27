# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::HubsController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:gothenburg) { FactoryBot.create(:gothenburg_hub, organization: organization) }
  let!(:user) { FactoryBot.create(:users_user) }
  let!(:felixstowe) { FactoryBot.create(:felixstowe_hub, organization: organization) }
  let!(:shanghai) { FactoryBot.create(:shanghai_hub, organization: organization) }

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    allow(controller).to receive(:doorkeeper_authorize!).and_return(true)
    allow(controller).to receive(:current_organization).at_least(:once).and_return(organization)
    allow(controller).to receive(:current_user).at_least(:once).and_return(user)
  end

  describe "GET #index" do
    it "returns a response with paginated results" do
      get :index, params: {
        organization_id: gothenburg.organization.id, hub_type: gothenburg.hub_type, hub_status: gothenburg.hub_status
      }
      expect(response_data["hubsData"].pluck("id")).to match_array([gothenburg, felixstowe, shanghai].pluck(:id))
    end

    context "when filtered by country" do
      let(:params) do
        {
          organization_id: gothenburg.organization.id,
          country: "China",
          country_desc: true,
          name: "Shanghai"
        }
      end

      it "returns a response with paginated results filtered by country" do
        get :index, params: params

        expect(response_data["hubsData"].pluck("id")).to match_array([shanghai.id])
      end
    end

    context "when filtered by name" do
      let(:params) do
        {
          organization_id: gothenburg.organization.id,
          name_desc: true,
          name: "Felixstowe"
        }
      end

      it "returns a response with paginated results filtered by name" do
        get :index, params: params

        expect(response_data["hubsData"].pluck("id")).to match_array([felixstowe.id])
      end
    end

    context "when filtered by locode" do
      let(:params) do
        {
          organization_id: gothenburg.organization.id,
          locode_desc: true,
          locode: "CNSHA"
        }
      end

      it "returns a response with paginated results filtered by locode" do
        get :index, params: params

        expect(response_data["hubsData"].pluck("id")).to match_array([shanghai.id])
      end
    end

    context "when filtered by type" do
      let(:params) do
        {
          organization_id: gothenburg.organization.id,
          type_desc: true,
          type: "ocean"
        }
      end

      it "returns a response with paginated results filtered by type" do
        get :index, params: params
        expect(
          response_data["hubsData"].pluck("id")
        ).to match_array([felixstowe.id, gothenburg.id, shanghai.id])
      end
    end
  end

  describe "Get #options_search" do
    let(:hub_name) { "Test Hub" }

    before do
      FactoryBot.create(:legacy_hub, organization: organization, name: hub_name)
    end

    it "returns the hubs matching the query sent" do
      get :options_search, params: { organization_id: organization.id, query: "Test" }

      expect(response_data.pluck("label")).to include("#{hub_name} Port")
    end
  end

  describe "POST #upload" do
    let(:perform_request) do
      post :upload, params: {
        "file" => Rack::Test::UploadedFile.new(File.expand_path("../../test_sheets/spec_sheet.xlsx", __dir__)),
        :organization_id => organization.id
      }
    end

    context "when an error is raised" do
      let(:errors_arr) do
        [{ row_no: 1, reason: "A" },
          { row_no: 2, reason: "B" },
          { row_no: 3, reason: "C" },
          { row_no: 4, reason: "D" }]
      end
      let(:error) { { has_errors: true, errors: errors_arr } }

      let(:complete_email_job) { performed_jobs.find { |j| j[:args][0] == "UploadMailer" } }
      let(:resulted_errors) do
        complete_email_job[:args][3]["result"]["errors"].map { |err| err.except("_aj_symbol_keys") }
      end

      before do
        mock_uploader = instance_double("ExcelDataServices::Loaders::Uploader", perform: error)
        allow(ExcelDataServices::Loaders::Uploader).to receive(:new).and_return(mock_uploader)

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
    context "when it succesfully downloads" do
      before do
        FactoryBot.create(:gothenburg_hub,
          free_out: false, organization: organization,
          mandatory_charge: FactoryBot.create(:mandatory_charge),
          nexus: FactoryBot.create(:gothenburg_nexus))
      end

      it "returns the hub file url" do
        get :download, params: { organization_id: organization.id }

        expect(response_data["url"]).to include(organization.slug)
      end
    end
  end

  describe "POST #set_status" do
    context "when the hub is active" do
      it "sets the hub status to inactive" do
        post :set_status, params: { hub_id: gothenburg.id, organization_id: organization.id }

        expect(response_data.dig("data", "hub_status")).to eq("inactive")
      end
    end
  end

  describe "GET #show" do
    it "returns the correct hub and related data" do
      get :show, params: { id: gothenburg.id, organization_id: organization.id }

      expect(response_data.keys).to match_array(%w[hub routes relatedHubs schedules address mandatoryCharge])
    end
  end

  describe "POST #update_mandatory_charges" do
    let!(:desired_mandatory_charge) do
      FactoryBot.create(:mandatory_charge,
        import_charges: true,
        export_charges: false,
        pre_carriage: false,
        on_carriage: false)
    end

    let(:params) do
      {
        mandatoryCharge: {
          import_charges: true,
          export_charges: false,
          pre_carriage: false,
          on_carriage: false
        },
        id: gothenburg.id,
        organization_id: organization.id
      }
    end

    it "sets the hub mandatory charge to the desired mandatory_charge" do
      post :update_mandatory_charges, params: params

      expect(response_data.dig("hub", "mandatory_charge_id")).to eq(desired_mandatory_charge.id)
    end
  end
end
