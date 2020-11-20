# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::SchedulesController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:organizations_membership) {
    FactoryBot.create(:organizations_membership, role: :admin, organization: organization, member: user)
  }

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    append_token_header
  end

  describe "GET #index" do
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:carrier) { FactoryBot.create(:carrier, name: "MSC") }
    let(:tenant_vehicle) { FactoryBot.create(:tenant_vehicle, carrier: carrier) }
    let(:closing_date) { Time.zone.today }
    let(:start_date) { Time.zone.today + 4.days }
    let(:end_date) { Time.zone.today + 30.days }

    before do
      (1..10).map do |delta|
        FactoryBot.create(:legacy_trip,
          itinerary: itinerary,
          closing_date: closing_date + delta.days,
          start_date: start_date + delta.days,
          end_date: end_date + delta.days,
          tenant_vehicle: tenant_vehicle)
      end
      get :index, params: {organization_id: organization.id}
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:carrier) { FactoryBot.create(:carrier, name: "MSC") }
    let(:tenant_vehicle) { FactoryBot.create(:tenant_vehicle, carrier: carrier) }
    let(:tenant_vehicle_no_carrier) { FactoryBot.create(:tenant_vehicle, carrier: nil) }
    let(:closing_date) { Time.zone.today }
    let(:start_date) { Time.zone.today + 4.days }
    let(:end_date) { Time.zone.today + 30.days }
    let(:show_params) do
      {
        id: itinerary.id,
        organization_id: organization.id
      }
    end

    before do
      (1..10).map do |delta|
        FactoryBot.create(:legacy_trip,
          itinerary: itinerary,
          closing_date: closing_date + delta.days,
          start_date: start_date + delta.days,
          end_date: end_date + delta.days,
          tenant_vehicle: tenant_vehicle)
      end
      FactoryBot.create(:legacy_trip,
        itinerary: itinerary,
        closing_date: closing_date + 2.days,
        start_date: start_date + 2.days,
        end_date: end_date + 2.days,
        tenant_vehicle: tenant_vehicle_no_carrier)
      get :show, params: show_params
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns the edited data" do
      aggregate_failures do
        expect(JSON.parse(response.body).dig("data", "schedules").length).to eq 11
        expect(JSON.parse(response.body).dig("data", "schedules", 0, "carrier")).to eq "MSC"
        expect(JSON.parse(response.body).dig("data", "schedules", 0, "service_level")).to eq "standard"
      end
    end
  end

  context "when uploading schedules" do
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
      excel_data_service = instance_double("ExcelDataServices::Loaders::Uploader", perform: error)
      allow(ExcelDataServices::Loaders::Uploader).to receive(:new).and_return(excel_data_service)

      allow(controller).to receive(:current_organization).and_return(organization)
    end

    describe "POST #upload" do
      let(:perform_request) {
        post :upload, params: {
          "file" => Rack::Test::UploadedFile.new(File.expand_path("../../test_sheets/spec_sheet.xlsx", __dir__)),
          :organization_id => organization.id
        }
      }

      it_behaves_like "uploading request async"

      it "sends an email with the upload errors" do
        perform_enqueued_jobs do
          perform_request
        end

        expect(resulted_errors).not_to be_empty
      end
    end

    describe "POST #generate_schedules_from_sheet" do
      let(:perform_request) {
        post :generate_schedules_from_sheet, params: {
          "file" => Rack::Test::UploadedFile.new(File.expand_path("../../test_sheets/spec_sheet.xlsx", __dir__)),
          :organization_id => organization.id, :mot => "ocean", :load_type => "cargo_item"
        }
      }

      it_behaves_like "uploading request async"

      it "sends an email with the upload errors" do
        perform_enqueued_jobs do
          perform_request
        end

        expect(resulted_errors).not_to be_empty
      end
    end
  end
end
