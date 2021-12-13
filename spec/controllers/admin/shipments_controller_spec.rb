# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ShipmentsController, type: :controller do
  include_context "journey_complete_request"

  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:json_response) { JSON.parse(response.body) }
  let(:route_sections) { [freight_section] }
  let(:line_items) { freight_line_items_with_cargo }

  before do
    FactoryBot.create(:legacy_hub,
      hub_code: freight_section.from.locode,
      hub_type: freight_section.mode_of_transport,
      organization: organization)
    FactoryBot.create(:legacy_hub,
      hub_code: freight_section.to.locode,
      hub_type: freight_section.mode_of_transport,
      organization: organization)
    Organizations.current_id = organization.id
    breakdown
    FactoryBot.create(:users_membership, organization: organization, user: user)
    append_token_header
  end

  describe "GET #index" do
    before do
      FactoryBot.create(:journey_result, :empty, sections: 0, query: query.dup)
    end

    it "returns an http status of success" do
      get :index, params: { organization_id: organization }

      expect(response_data["quoted"].map { |res| res["id"] }).to match([result.id])
    end

    context "when a user has been deleted" do
      before do
        client.destroy
      end

      it "returns an http status of success" do
        get :index, params: { organization_id: organization }

        expect(response).to have_http_status(:success)
      end
    end

    context "when a user is nil" do
      before do
        query.update(client_id: nil)
      end

      it "returns an http status of success", :aggregate_failures do
        get :index, params: { organization_id: organization.id }

        expect(response).to have_http_status(:success)
        expect(json.dig(:data, :quoted).pluck(:id)).to include(result.id)
      end
    end

    context "when a user id is given" do
      let(:other_query) { FactoryBot.create(:journey_query, organization: organization) }
      let(:result_ids) { json.dig(:data, :quoted).pluck(:id) }

      it "returns an http status of success", :aggregate_failures do
        get :index, params: { organization_id: organization.id, target_user_id: query.client_id }

        expect(response).to have_http_status(:success)
        expect(result_ids).to match_array([result.id])
      end
    end

    context "when a hub_type is given" do
      it "returns an http status of success", :aggregate_failures do
        get :index, params: { organization_id: organization.id, hub_type: "ocean" }

        expect(response).to have_http_status(:success)
        expect(json.dig(:data, :quoted).pluck(:id)).to include(result.id)
      end
    end

    context "when a origin_nexus is given" do
      let(:nexus) { FactoryBot.create(:legacy_nexus, locode: origin_locode) }

      it "returns an http status of success", :aggregate_failures do
        get :index, params: { organization_id: organization.id, origin_nexus: nexus.id }

        expect(response).to have_http_status(:success)
        expect(json.dig(:data, :quoted).pluck(:id)).to include(result.id)
      end
    end

    context "when a destination_nexus is given" do
      let(:nexus) { FactoryBot.create(:legacy_nexus, locode: destination_locode) }

      it "returns an http status of success", :aggregate_failures do
        get :index, params: { organization_id: organization.id, destination_nexus: nexus.id }

        expect(response).to have_http_status(:success)
        expect(json.dig(:data, :quoted).pluck(:id)).to include(result.id)
      end
    end

    context "when billable is given" do
      let(:query_billable) { FactoryBot.create(:journey_query, organization: organization, billable: false) }

      it "returns an http status of success", :aggregate_failures do
        get :index, params: { organization_id: organization.id, billable: false }

        expect(response).to have_http_status(:success)
        expect(json.dig(:data, :quoted).pluck(:billable)).not_to include(!query_billable.billable)
      end
    end
  end

  describe "GET #search_shipments" do
    it "returns the matching shipments for the client" do
      get :search_shipments, params: { target: "requested", query: client.profile.first_name, organization_id: organization.id }

      expected_client_name = "#{client.profile.first_name} #{client.profile.last_name}"
      expect(json.dig(:data, :shipments).first[:client_name]).to eq(expected_client_name)
    end

    context "when searching via POL" do
      it "returns matching shipments with origin matching the query" do
        get :search_shipments, params: {
          target: "requested", query: query.origin, organization_id: organization.id
        }
        expect(json.dig(:data, :shipments).first[:id]).to eq(result.id)
      end
    end

    context "when searching via client's company name/Agency" do
      it "returns matching shipments with clients matching the company name in query" do
        get :search_shipments, params: {
          target: "requested", query: client.profile.company_name, organization_id: organization.id
        }
        expect(json.dig(:data, :shipments).first[:id]).to eq(result.id)
      end
    end
  end

  describe "GET #show" do
    before do
      %w[
        trucking_pre
        trucking_on
        cargo
        export
        import
      ].each do |code|
        FactoryBot.create(:legacy_charge_categories, code: code, name: code.humanize, organization: organization)
      end
    end

    let(:expected_keys) do
      %w[shipment cargoItems containers aggregatedCargo contacts documents
        addresses cargoItemTypes accountHolder pricingBreakdowns]
    end

    context "when lcl" do
      it "returns the shipment object sent in the parameters", :aggregate_failures do
        get :show, params: { id: result.id, organization_id: organization.id }

        expect(json_response["data"]["shipment"]["id"]).to eq(result.id)
        expect(json_response["data"].keys).to match_array(expected_keys)
      end
    end

    context "when fcl" do
      let(:cargo_unit_params) do
        [
          {
            cargo_class: "fcl_20",
            height_value: 1,
            length_value: 1,
            quantity: 1,
            stackable: true,
            weight_value: 1000,
            width_value: 1
          }
        ]
      end

      it "returns the shipment object sent in the parameters" do
        get :show, params: { id: result.id, organization_id: organization.id }

        expect(json_response["data"]["containers"]).to be_present
      end
    end

    context "when aggregated" do
      let(:cargo_unit_params) do
        [
          {
            cargo_class: "aggregated_lcl",
            volume_value: 1,
            quantity: 1,
            stackable: true,
            weight_value: 1000
          }
        ]
      end

      it "returns the shipment object sent in the parameters" do
        get :show, params: { id: result.id, organization_id: organization.id }

        expect(json_response["data"]["aggregatedCargo"]).to be_present
      end
    end
  end

  describe "GET #delta_page_handler" do
    it "returns shipments matching the target in params" do
      get :delta_page_handler, params: { target: "quoted", organization_id: organization.id }

      expect(json_response.dig("data", "shipments").count).to eq(1)
    end
  end
end
