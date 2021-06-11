# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::MarginsController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_vehicle_1) {
    FactoryBot.create(:tenant_vehicle, name: "slowly", organization: organization)
  }
  let(:organization_vehicle_2) {
    FactoryBot.create(:tenant_vehicle, name: "faster", organization: organization)
  }
  let!(:user) { FactoryBot.create(:users_user, organization_id: organization.id) }
  let!(:currency) { user.settings.currency }
  let(:itinerary_1) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:company) { FactoryBot.create(:companies_company, name: "Test", organization: organization) }
  let!(:membership) { FactoryBot.create(:companies_membership, company: company, member: user) }
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:group) do
    group = FactoryBot.create(:groups_group, organization: organization)
    FactoryBot.create(:groups_membership, member: user, group: group)
    group
  end
  let(:json_response) { JSON.parse(response.body) }
  let(:lcl_pricing) { FactoryBot.create(:lcl_pricing, tenant_vehicle: organization_vehicle_1, itinerary: itinerary_1) }

  before do
    ::Organizations.current_id = organization.id
    append_token_header
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
      context "<<" do
        before do
          FactoryBot.create(:pricings_margin, organization: organization, applicable: target)
        end

        it "returns the margins for the specified target" do
          get :index, params: {organization_id: organization.id, target_type: target_type, target_id: target.id}
          aggregate_failures do
            expect(json_response.dig("data", "marginData").count).to be >= 1
          end
        end
      end
    end

    context "Searching for company margins" do
      it_should_behave_like "a searchable margin target" do
        let(:target) { FactoryBot.create(:companies_company, name: "Test 2", organization: organization) }
        let(:target_type) { "company" }
      end
    end

    context "Searching for group margins" do
      it_should_behave_like "a searchable margin target" do
        let(:target) { group }
        let(:target_type) { "group" }
      end
    end

    context "Searching for user margins" do
      it_should_behave_like "a searchable margin target" do
        let(:target) { client }
        let(:target_type) { "user" }
      end
    end

    context "Searching for organization margins" do
      it_should_behave_like "a searchable margin target" do
        let(:target) { organization }
        let(:target_type) { "tenant" }
      end
    end

    context "Searching for itinerary margins" do
      before do
        FactoryBot.create(:pricings_margin, itinerary: itinerary_1, organization: organization)
      end

      it_should_behave_like "a searchable margin target" do
        let(:target) { itinerary_1 }
        let(:target_type) { "itinerary" }
      end
    end
  end

  describe "POST #test" do
    let(:args) do
      {
        selectedOriginHub: itinerary_1.hubs.first.id,
        selectedDestinationHub: itinerary_1.hubs.last.id,
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
            margin: user_margin, service_level: organization_vehicle_1)
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
            service_level: organization_vehicle_1)
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
            service_level: organization_vehicle_1)
        )
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

    it_behaves_like "uploading request async"
  end

  describe "GET #form_data" do
    before do
      FactoryBot.create_list(:lcl_pricing, 3, itinerary: itinerary_1, tenant_vehicle: organization_vehicle_1)
      FactoryBot.create(:groups_group, organization: organization)
    end

    context "when requested with an itinerary id" do
      it "returns the service levels, pricings, and groups for the itinerary and organization" do
        get :form_data, params: {organization_id: organization, itinerary_id: itinerary_1.id}
        aggregate_failures do
          expect(json_response.dig("data", "service_levels").count).to eq(3)
          expect(json_response.dig("data", "pricings").count).to eq(3)
          expect(json_response.dig("data", "groups").count).to eq(2)
        end
      end
    end

    context "when requested without an itinerary id" do
      let(:organization_3) { FactoryBot.create(:organizations_organization) }

      before do
        FactoryBot.create(:tenant_vehicle, name: "1", organization: organization_3)
        FactoryBot.create(:tenant_vehicle, name: "2", organization: organization_3)
        FactoryBot.create_list(:groups_group, 2, organization: organization_3)
        ::Organizations.current_id = organization_3.id
      end

      it "returns the groups and service levels (tenant vehicles) of the organization" do
        get :form_data, params: {organization_id: organization_3.id}
        aggregate_failures do
          expect(json_response.dig("data", "groups").count).to eq(2)
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
      get :itinerary_list, params: {organization_id: organization.id, query: "Hamburg"}
      aggregate_failures do
        target_name = json_response.dig("data").last.dig("value", "name")
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
        operand: {value: "+"},
        attached_to: "itinerary",
        marginValue: 10,
        fineFeeValues: {"BAS - Basic Freight" => {value: 10, operand: {value: "+"}}},
        effective_date: Time.zone.now,
        expiration_date: Time.zone.now + 6.months
      }
    end
    let(:new_margin) { json_response.dig("data").first }

    it "returns the newly created Margin" do
      post :create, params: params
      aggregate_failures do
        expect(new_margin.dig("cargoClass")).to eq(params[:cargo_classes].first)
        expect(new_margin.dig("operator")).to eq(params.dig(:operand, :value))
        expect(new_margin.dig("marginDetails").length).to eq(1)
        expect(new_margin.dig("marginDetails", 0, "value")).to eq("10.0")
      end
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
        FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: organization_vehicle_1)
        itinerary.hubs.each do |hub|
          FactoryBot.create(:legacy_local_charge,
            hub: hub,
            organization: organization,
            tenant_vehicle: organization_vehicle_1,
            load_type: "lcl")
        end
      end

      it "returns the compound local charges for the specified itinerary" do
        get :fee_data, params: params
        aggregate_failures do
          expect(json_response.dig("data")).to include(expected_fee_value)
        end
      end
    end

    describe "querying fee data with no margin type" do
      let(:pricing) {
        FactoryBot.create(:lcl_pricing, itinerary: itinerary,
                                        tenant_vehicle: organization_vehicle_1,
                                        organization: organization)
      }

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
            expect(json_response.dig("data")).to include(expected_fee_value)
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
            tenant_vehicle: organization_vehicle_1)
        end

        it "returns the fees for the pricings matching the params sent" do
          get :fee_data, params: params
          aggregate_failures do
            expect(json_response.dig("data")).to include(expected_fee_value)
          end
        end

        it "gets the fees for all pricings if an itinerary id isnt specified" do
          params.delete(:itinerary_id)
          get :fee_data, params: params
          aggregate_failures do
            expect(json_response.dig("data")).to include(expected_fee_value)
          end
        end
      end
    end
  end

  describe "POST update_multiple" do
    let(:margin) { FactoryBot.create(:pricings_margin, organization: organization) }
    let(:margin_detail) {FactoryBot.create(:pricings_detail, margin: margin) }
    let(:params) do
      {
        margins: [
          margin.as_json.transform_keys {|key| key.camelize(:lower) }.merge(
            "value" => 155,
            "operator" => "+",
            "marginDetails" => [
              margin_detail.as_json.merge(
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
end
