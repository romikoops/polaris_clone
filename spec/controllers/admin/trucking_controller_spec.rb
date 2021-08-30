# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::TruckingController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:user) { FactoryBot.create(:users_user) }
  let(:hub) { FactoryBot.create(:legacy_hub, organization: organization) }
  let(:json_response) { JSON.parse(response.body) }

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    append_token_header
  end

  describe "POST #upload" do
    before do
      allow(ExcelDataServices::UploaderJob).to receive(:perform_later)
      allow(ExcelDataServices::Upload).to receive(:create!).and_return(dummy_upload)
    end

    let(:base_params) do
      {
        file: Rack::Test::UploadedFile.new(File.expand_path("../../test_sheets/spec_sheet.xlsx", __dir__)),
        organization_id: organization.id,
        id: hub.id
      }
    end
    let(:dummy_upload) { FactoryBot.create(:excel_data_services_upload) }

    context "when missing the param" do
      it "the request is unsuccessful without the param group_id" do
        expect { post :upload, params: base_params }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when the group is set to general" do
      before { post :upload, params: base_params.merge(group_id: "all") }

      it "returns error with messages when an error is raised" do
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json_response["data"]).to be_truthy
        end
      end
    end

    context "when the group id is provided" do
      let(:group_id) { FactoryBot.create(:groups_group, organization: organization).id }

      before { post :upload, params: base_params.merge(group_id: group_id) }

      it "returns error with messages when an error is raised" do
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json_response["data"]).to be_truthy
          expect(ExcelDataServices::UploaderJob).to have_received(:perform_later).with(
            upload_id: dummy_upload.id,
            options: {
              user_id: user.id,
              group_id: group_id,
              hub_id: hub.id
            }
          )
        end
      end
    end
  end

  describe "GET #show" do
    let(:courier_name) { "Test Courier" }
    let(:group) { FactoryBot.create(:groups_group, organization: organization) }
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: courier_name) }
    let(:courier) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier, organization: organization, mode_of_transport: "truck_carriage") }
    let(:location) { FactoryBot.create(:trucking_location) }

    before do
      FactoryBot.create(:trucking_trucking, hub: hub, tenant_vehicle: courier, organization: organization, group: group, location: location)
    end

    it "returns the truckings for the requested hub" do
      get :show, params: { id: hub.id, organization_id: organization.id, group: group.id, courier: courier_name }
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response.dig("data", "groups")).not_to be_empty
        expect(json_response.dig("data", "truckingPricings").first.dig("truckingPricing", "hub_id")).to eq(hub.id)
        expect(json_response.dig("data", "providers")).to include(courier_name)
      end
    end

    context "with different types of location info for truckings" do
      before { location }

      context "when query type is location" do
        let(:location) { FactoryBot.create(:trucking_location, query: :location) }

        it "returns location with zipcode when query type is location" do
          get :show, params: { id: hub.id, organization_id: organization.id, group: group.id }
          expect(json_response.dig("data", "truckingPricings").first).to include({ "city" => location.data })
        end
      end

      context "when query type is zip code" do
        let(:location) { FactoryBot.create(:trucking_location, query: :postal_code) }

        it "returns location with zipcode when query type is postal_code" do
          get :show, params: { id: hub.id, organization_id: organization.id, group: group.id }
          expect(json_response.dig("data", "truckingPricings").first).to include({ "zipCode" => location.data })
        end
      end

      context "when query type is distance" do
        let(:location) { FactoryBot.create(:trucking_location, query: :distance) }

        it "returns location with zipcode when query type is distance" do
          get :show, params: { id: hub.id, organization_id: organization.id, group: group.id }
          expect(json_response.dig("data", "truckingPricings").first).to include({ "distance" => location.data })
        end
      end
    end
  end
end
