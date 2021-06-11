
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::MarginsController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:tenant_vehicle) do
    FactoryBot.create(:tenant_vehicle, name: "slowly", organization: organization)
  end

  let(:access_token) do
    Doorkeeper::AccessToken.create(
      resource_owner_id: user.id, scopes: "public", application: FactoryBot.build(:application, name: "dipper")
    )
  end
  let!(:user) { FactoryBot.create(:users_user) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:company) do
    FactoryBot.create(:companies_company,
      name: "Test",
      memberships: [FactoryBot.build(:companies_membership, member: client)],
      organization: organization)
  end
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:group) do
    FactoryBot.create(:groups_group,
      memberships: [FactoryBot.build(:groups_membership, member: client)],
      organization: organization)
  end
  let(:json_response) { JSON.parse(response.body) }
  let(:lcl_pricing) { FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle, itinerary: itinerary) }

  before do
    ::Organizations.current_id = organization.id
    token_header = "Bearer #{access_token.token}"
    request.headers["Authorization"] = token_header
    FactoryBot.create(:groups_group, :default, organization: organization)
    %w[ocean air rail truck trucking local_charge].map do |mot|
      [
        FactoryBot.create(
          :freight_margin, default_for: mot, organization: organization, applicable: organization, value: 0
        ),
        FactoryBot.create(
          :trucking_on_margin, default_for: mot, organization: organization, applicable: organization, value: 0
        ),
        FactoryBot.create(
          :trucking_pre_margin, default_for: mot, organization: organization, applicable: organization, value: 0
        ),
        FactoryBot.create(
          :import_margin, default_for: mot, organization: organization, applicable: organization, value: 0
        ),
        FactoryBot.create(
          :export_margin, default_for: mot, organization: organization, applicable: organization, value: 0
        )
      ]
    end
  end

  describe "Get #index" do
    shared_examples_for "a searchable margin target" do
      before do
        FactoryBot.create(:pricings_margin, organization: organization, applicable: target)
      end

      it "returns the margins for the specified target" do
        get :index, params: { organization_id: organization.id, target_type: target_type, target_id: target.id }
        aggregate_failures do
          expect(json_response.dig("data", "marginData").count).to be >= 1
        end
      end
    end

    context "when searching for company margins" do
      it_behaves_like "a searchable margin target" do
        let(:target) { FactoryBot.create(:companies_company, name: "Test 2", organization: organization) }
        let(:target_type) { "company" }
      end
    end

    context "when searching for group margins" do
      it_behaves_like "a searchable margin target" do
        let(:target) { group }
        let(:target_type) { "group" }
      end
    end

    context "when searching for user margins" do
      it_behaves_like "a searchable margin target" do
        let(:target) { client }
        let(:target_type) { "user" }
      end
    end

    context "when searching for organization margins" do
      it_behaves_like "a searchable margin target" do
        let(:target) { organization }
        let(:target_type) { "tenant" }
      end
    end

    context "when searching for itinerary margins" do
      before do
        FactoryBot.create(:pricings_margin, itinerary: itinerary, organization: organization)
      end

      it_behaves_like "a searchable margin target" do
        let(:target) { itinerary }
        let(:target_type) { "itinerary" }
      end
    end
  end

  describe "POST #test" do
    let(:args) do
      {
        selectedOriginHub: itinerary.hubs.first.id,
        selectedDestinationHub: itinerary.hubs.last.id,
        selectedCargoClass: "lcl",
        organization_id: organization.id
      }
    end
    let(:json) { JSON.parse(response.body) }
    let(:results) { json.dig("data", "results") }

    it "returns http success for a User target" do
      user_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing,
                                                       organization: organization, applicable: client)
      params = args.merge(targetId: client.id, targetType: "user")

      post :test, params: params

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(results.length).to eq(1)
        expect(
          results.first
        ).to include(
          FactoryBot.build(:margin_preview_result,
            target: client, target_name: "#{client.profile.first_name} #{client.profile.last_name}",
            margin: user_margin, service_level: tenant_vehicle)
        )
      end
    end

    it "returns http success for a Company target" do
      company_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, organization: organization,
                                                          applicable: company)
      params = args.merge(targetId: company.id, targetType: "company")

      post :test, params: params

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(results.length).to eq(1)
        expect(
          results.first
        ).to include(
          FactoryBot.build(:margin_preview_result,
            target: company, target_name: company.name, margin: company_margin,
            service_level: tenant_vehicle)
        )
      end
    end

    it "returns http success for a Group target" do
      group_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, organization: organization,
                                                        applicable: group)
      params = args.merge(targetId: group.id, targetType: "group")

      post :test, params: params

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(results.length).to eq(1)
        expect(results.first).to include(
          FactoryBot.build(:margin_preview_result,
            target: group, target_name: group.name, margin: group_margin,
            service_level: tenant_vehicle)
        )
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

    it_behaves_like "uploading request async"
  end

  describe "GET #form_data" do
    context "when requested with an itinerary id" do
      before do
        FactoryBot.create_list(:lcl_pricing, 3, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
        FactoryBot.create(:groups_group, organization: organization)
      end

      it "returns the service levels, pricings, and groups for the itinerary and organization", :aggregate_failures do
        get :form_data, params: { organization_id: organization, itinerary_id: itinerary.id }
        expect(json_response.dig("data", "service_levels").count).to eq(3)
        expect(json_response.dig("data", "pricings").count).to eq(3)
        expect(json_response.dig("data", "groups").count).to eq(2)
      end
    end

    context "when requested without an itinerary id" do
      before do
        FactoryBot.create(:tenant_vehicle, name: "1", organization: organization)
        FactoryBot.create(:tenant_vehicle, name: "2", organization: organization)
        FactoryBot.create_list(:groups_group, 2, organization: organization)
      end

      it "returns the groups and service levels (tenant vehicles) of the organization" do
        get :form_data, params: { organization_id: organization.id }
        aggregate_failures do
          expect(json_response.dig("data", "groups").count).to eq(3)
          expect(json_response.dig("data", "service_levels").count).to eq(2)
        end
      end
    end
  end

  describe "Get #itinerary_list" do
    before do
      FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization)
    end

    it "returns the  (formatted) list of itineraries requested by the query" do
      get :itinerary_list, params: { organization_id: organization.id, query: "Hamburg" }
      aggregate_failures do
        target_name = json_response["data"].last.dig("value", "name")
        expect(target_name).to eq("Hamburg - Shanghai")
      end
    end
  end

  describe "Post #create" do
    let(:itinerary) do
      FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization)
    end
    let(:group) do
      FactoryBot.create(:groups_group, organization: organization)
    end
    let(:params) do
      {
        organization_id: organization.id,
        query: "Hamburg",
        itinerary_ids: [itinerary.id],
        hub_ids: [],
        cargo_classes: ["lcl"],
        marginType: "freight",
        groupId: group.id,
        directions: ["export"],
        operand: { value: "+" },
        attached_to: "itinerary",
        marginValue: 10,
        fineFeeValues: { "BAS - Basic Freight" => { value: 10, operand: { value: "+" } } },
        effective_date: Time.zone.now,
        expiration_date: Time.zone.now + 6.months
      }
    end
    let(:new_margin) { json_response["data"].first }

    it "returns the newly created Margin", :aggregate_failures do
      post :create, params: params
      expect(new_margin["cargoClass"]).to eq(params[:cargo_classes].first)
      expect(new_margin["operator"]).to eq(params.dig(:operand, :value))
      expect(new_margin["marginDetails"].length).to eq(1)
      expect(new_margin.dig("marginDetails", 0, "value")).to eq("10.0")
    end
  end

  describe "Get #fee_data" do
    let(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization) }

    context "with margin type: local charges" do
      let(:expected_fee_value) { "SOLAS - SOLAS" }
      let(:params) do
        {
          organization_id: organization.id,
          itinerary_id: itinerary.id,
          cargo_classes: "all",
          hub_ids: itinerary.hubs.pluck(:id),
          tenant_vehicle_ids: "all",
          margin_type: "local_charges",
          directions: "export"
        }
      end

      before do
        FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
        itinerary.hubs.each do |hub|
          FactoryBot.create(:legacy_local_charge,
            hub: hub,
            organization: organization,
            tenant_vehicle: tenant_vehicle,
            load_type: "lcl")
        end
      end

      it "returns the compound local charges for the specified itinerary" do
        get :fee_data, params: params
        aggregate_failures do
          expect(json_response["data"]).to include(expected_fee_value)
        end
      end
    end

    describe "querying fee data with no margin type" do
      let(:pricing) do
        FactoryBot.create(:lcl_pricing, itinerary: itinerary,
                                        tenant_vehicle: tenant_vehicle,
                                        organization: organization)
      end

      context "when requested with pricing id" do
        let(:expected_fee_value) { "BAS - Basic Ocean Freight" }
        let(:params) do
          {
            pricing_id: pricing.id,
            organization_id: organization.id
          }
        end

        it "returns the formatted list of fees for the specified pricing" do
          get :fee_data, params: params
          aggregate_failures do
            expect(json_response["data"]).to include(expected_fee_value)
          end
        end
      end

      context "when requested without pricing id" do
        let(:expected_fee_value) { "BAS - Basic Ocean Freight" }
        let(:params) do
          {
            organization_id: organization.id,
            itinerary_id: itinerary.id,
            itinerary_ids: [itinerary.id],
            cargo_classes: "all",
            tenant_vehicle_ids: "all",
            directions: "export"
          }
        end

        before do
          FactoryBot.create(:lcl_pricing,
            organization: organization,
            itinerary: itinerary,
            tenant_vehicle: tenant_vehicle)
        end

        it "returns the fees for the pricings matching the params sent" do
          get :fee_data, params: params
          aggregate_failures do
            expect(json_response["data"]).to include(expected_fee_value)
          end
        end

        it "gets the fees for all pricings if an itinerary id isnt specified" do
          params.delete(:itinerary_id)
          get :fee_data, params: params
          aggregate_failures do
            expect(json_response["data"]).to include(expected_fee_value)
          end
        end
      end
    end
  end

  describe "POST update_multiple" do
    let(:margin) { FactoryBot.create(:pricings_margin, organization: organization) }
    let(:margin_detail) { FactoryBot.create(:pricings_detail, margin: margin) }
    let(:params) do
      {
        margins: [
          margin.as_json.transform_keys { |key| key.camelize(:lower) }.merge(
            "value" => 155,
            "operator" => "+",
            "marginDetails" => [
              margin_detail.as_json.transform_keys { |key| key.camelize(:lower) }.merge(
                "value" => 0.5,
                "operator" => "%"
              )
            ]
          )
        ],
        organization_id: organization.id
      }
    end

    before do
      Organizations.current_id = organization.id
    end

    context "when margin and detail exists" do
      before do
        post :update_multiple, params: params
        margin.reload
        margin_detail.reload
      end

      it "updates the margin and margin detail", :aggregate_failures do
        expect(margin.value).to eq(155)
        expect(margin.operator).to eq("+")
        expect(margin_detail.value).to eq(0.5)
        expect(margin_detail.operator).to eq("%")
      end
    end

    context "when Margin is not found" do
      before do
        post :update_multiple, params: new_params
      end

      let(:new_params) do
        params.dup.tap do |par|
          par[:margins].first["id"] = ""
          par
        end
      end

      it "raises an error" do
        expect(response.status).to eq(404)
      end
    end

    context "when MarginDetail is not found" do
      before do
        post :update_multiple, params: new_params
      end

      let(:new_params) do
        params.dup.tap do |par|
          par[:margins].first["marginDetails"].first["id"] = ""
          par
        end
      end

      it "raises an error" do
        expect(response.status).to eq(404)
      end
    end
  end
end
