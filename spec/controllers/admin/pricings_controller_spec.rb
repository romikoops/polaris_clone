# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::PricingsController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization, slug: "demo") }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:itinerary) do
    FactoryBot.create(:itinerary, organization_id: organization.id)
  end
  let(:json_response) { JSON.parse(response.body) }

  before do
    append_token_header
  end

  describe "GET #route" do
    let!(:pricings) do
      [
        FactoryBot.create(:pricings_pricing, organization: organization, itinerary_id: itinerary.id),
        FactoryBot.create(:pricings_pricing, organization: organization,
                                             itinerary_id: itinerary.id,
                                             effective_date: DateTime.new(2019, 1, 1),
                                             expiration_date: DateTime.new(2019, 1, 31))
      ]
    end
    let(:expected_response) do
      pricings_table_jsons = [
        { "id" => pricings.first.id,
          "effective_date" => pricings.first.effective_date,
          "expiration_date" => pricings.first.expiration_date,
          "group_id" => default_group.id,
          "internal" => false,
          "itinerary_id" => itinerary.id,
          "organization_id" => organization.id,
          "tenant_vehicle_id" => pricings.first.tenant_vehicle_id,
          "wm_rate" => "1000.0",
          "vm_rate" => "1.0",
          "data" => {},
          "load_type" => "cargo_item",
          "cargo_class" => "lcl",
          "carrier" => pricings.first.tenant_vehicle.carrier.name,
          "service_level" => "standard",
          "itinerary_name" => "Gothenburg - Shanghai",
          "mode_of_transport" => "ocean" }
      ]

      stops = itinerary.stops
      first_stop = stops.first
      second_stop = stops.second
      stops_table_jsons = [
        { "id" => first_stop.id,
          "hub_id" => first_stop.hub_id,
          "index" => 0,
          "itinerary_id" => itinerary.id,
          "hub" => { "id" => first_stop.hub_id, "name" => "Gothenburg", "nexus" => {
            "id" => first_stop.hub.nexus.id, "name" => "Gothenburg"
          }, "address" => {
            "geocoded_address" => "438 80 Landvetter, Sweden", "latitude" => 57.694253, "longitude" => 11.854048
          } } },
        { "id" => second_stop.id,
          "hub_id" => second_stop.hub_id,
          "index" => 1,
          "itinerary_id" => itinerary.id,
          "hub" => { "id" => second_stop.hub_id, "name" => "Gothenburg", "nexus" => {
            "id" => second_stop.hub.nexus.id, "name" => "Gothenburg"
          }, "address" => {
            "geocoded_address" => "438 80 Landvetter, Sweden",
            "latitude" => 57.694253, "longitude" => 11.854048
          } } }
      ]

      JSON.parse({ pricings: pricings_table_jsons,
                   itinerary: itinerary,
                   stops: stops_table_jsons }.to_json)
    end

    it "returns the correct data for the route" do
      get :route, params: { organization_id: organization.id, id: itinerary.id }
      expect(JSON.parse(response.body)["data"]).to eq(expected_response)
    end

    context "with effective pricing date is in future" do
      let(:pricings) do
        [
          FactoryBot.create(:pricings_pricing, organization: organization,
                                               itinerary_id: itinerary.id,
                                               effective_date: Time.zone.today + 1)
        ]
      end

      it "returns pricings with future effective pricing date" do
        get :route, params: { organization_id: organization.id, id: itinerary.id }
        expect(JSON.parse(response.body)["data"]).to eq(expected_response)
      end
    end
  end

  describe "POST #upload" do
    let(:perform_request) do
      post :upload, params: {
        "file" => Rack::Test::UploadedFile.new(File.expand_path("../../test_sheets/spec_sheet.xlsx", __dir__)),
        :organization_id => organization.id
      }
    end

    context "when error testing" do
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
        excel_service = instance_double("ExcelDataServices::Loaders::Uploader", perform: error)
        allow(ExcelDataServices::Loaders::Uploader).to receive(:new).and_return(excel_service)

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
    let(:organization) { FactoryBot.create(:organizations_organization, slug: "demo") }
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
    let(:itinerary_with_stops) do
      FactoryBot.create(:itinerary, organization: organization,
                                    stops: [
                                      FactoryBot.build(:stop, itinerary_id: nil, index: 0, hub: hubs.first),
                                      FactoryBot.build(:stop, itinerary_id: nil, index: 1, hub: hubs.second)
                                    ])
    end
    let(:tenant_vehicle) do
      FactoryBot.create(:tenant_vehicle, organization: organization)
    end

    context "when calculating cargo_item" do
      before do
        FactoryBot.create(:lcl_pricing)
        get :download, params: {
          organization_id: organization.id, options: { mot: "ocean", load_type: "cargo_item", group_id: nil }
        }
      end

      it "returns error with messages when an error is raised" do
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json_response.dig("data", "url")).to include("demo__pricings_ocean_lcl.xlsx")
        end
      end
    end

    context "when a container" do
      before do
        FactoryBot.create(:fcl_20_pricing)
        get :download, params: {
          organization_id: organization.id, options: { mot: "ocean", load_type: "container", group_id: nil }
        }
      end

      it "returns error with messages when an error is raised" do
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json_response.dig("data", "url")).to include("demo__pricings_ocean_fcl.xlsx")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when base_pricing" do
      before do
        delete :destroy, params: { "id" => base_pricing.id, :organization_id => organization.id }
      end

      let(:base_pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }

      it "deletes the Pricings::Pricing" do
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(Pricings::Pricing.exists?(id: base_pricing.id)).to eq(false)
        end
      end
    end
  end

  describe "GET #index" do
    let!(:itinerary) do
      FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization)
    end

    let!(:itinerary_two) do
      FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization)
    end

    before do
      FactoryBot.create(:pricings_pricing, organization: organization, itinerary_id: itinerary.id)
      FactoryBot.create(:pricings_pricing, organization: organization, itinerary_id: itinerary_two.id)
    end

    context "with base params" do
      before do
        post :index, params: { organization_id: organization.id }
      end

      it "returns an http status of success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the pricing data for the itineraries" do
        json = JSON.parse(response.body)
        expect(json.dig("data", "pricingData").collect { |m| m["id"] }.sort).to eq(Legacy::Itinerary.pluck(:id).sort)
      end
    end

    context "with name search" do
      before do
        post :index, params: { organization_id: organization.id, name: "gothenburg" }
      end

      it "returns the pricing data for the searched itinerary" do
        json = JSON.parse(response.body)
        expect(json.dig("data", "pricingData", 0, "id")).to eq(itinerary.id)
      end
    end

    context "with name search with no matches" do
      before do
        post :index, params: { organization_id: organization.id, name: "" }
      end

      it "returns the pricing data for the searched itinerary" do
        json = JSON.parse(response.body)
        expect(json.dig("data", "pricingData").length).to eq(0)
      end
    end
  end

  describe "GET #group" do
    let(:group) do
      FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
        FactoryBot.create(:groups_membership, group: tapped_group, member: user)
      end
    end
    let!(:pricing) do
      FactoryBot.create(:lcl_pricing,
        itinerary: itinerary,
        group_id: group.id,
        effective_date: DateTime.now - 30.days,
        expiration_date: DateTime.now + 30.days)
    end
    let!(:pricing_two) do
      FactoryBot.create(:fcl_20_pricing,
        itinerary: itinerary,
        group_id: group.id,
        effective_date: DateTime.now - 29.days,
        expiration_date: DateTime.now + 31.days)
    end

    context "with base params" do
      before do
        post :group, params: { id: group.id, organization_id: organization.id }
      end

      it "returns an http status of success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the pricings for the group" do
        json = JSON.parse(response.body)
        expect(json.dig("data", "pricings").collect { |m| m["id"] }.sort).to eq(Pricings::Pricing.pluck(:id).sort)
      end
    end

    context "with effective_date params" do
      before do
        post :group, params: { id: group.id, organization_id: organization.id, effective_date_desc: true }
      end

      it "returns the pricings in descending order of effective date" do
        json = JSON.parse(response.body)
        expect(json.dig("data", "pricings", 0, "id")).to eq(pricing_two.id.to_s)
      end
    end

    context "with expiration params" do
      before do
        post :group, params: { id: group.id, organization_id: organization.id, expiration_date_desc: true }
      end

      it "returns the pricings in descending order of expiration date" do
        json = JSON.parse(response.body)
        expect(json.dig("data", "pricings", 0, "id")).to eq(pricing_two.id.to_s)
      end
    end

    context "with load type params" do
      before do
        post :group, params: { id: group.id, organization_id: organization.id, load_type: "cargo" }
      end

      it "returns the pricings that match the load type query" do
        json = JSON.parse(response.body)
        expect(json.dig("data", "pricings", 0, "id")).to eq(pricing.id.to_s)
      end
    end

    context "with load type desc params" do
      before do
        post :group, params: { id: group.id, organization_id: organization.id, load_type_desc: true }
      end

      it "returns the pricings in descending order of load type alphabetically" do
        json = JSON.parse(response.body)
        expect(json.dig("data", "pricings", 0, "id")).to eq(pricing_two.id.to_s)
      end
    end

    context "with cargo class params" do
      before do
        post :group, params: { id: group.id, organization_id: organization.id, cargo_class: "fcl" }
      end

      it "returns the pricings that match the cargo class query" do
        json = JSON.parse(response.body)
        expect(json.dig("data", "pricings", 0, "id")).to eq(pricing_two.id.to_s)
      end
    end
  end

  describe "POST #disable" do
    let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization, itinerary_id: itinerary.id) }

    context "when enabling pricing" do
      before do
        pricing.update(internal: true)
      end

      it "toggles the internal state of the pricing to true", :aggregate_failures do
        post :disable, params: { pricing_id: pricing.id, id: pricing.id, organization_id: organization.id, target_action: "enable" }
        expect(response).to have_http_status(:success)
        pricing.reload
        expect(pricing.internal).to eq(false)
      end
    end

    context "when disabling pricing'" do
      before do
        pricing.update(internal: false)
      end

      it "toggles the internal state of the pricing to true", :aggregate_failures do
        post :disable, params: { pricing_id: pricing.id, id: pricing.id, organization_id: organization.id, target_action: "disable" }
        expect(response).to have_http_status(:success)
        pricing.reload
        expect(pricing.internal).to eq(true)
      end
    end
  end
end
