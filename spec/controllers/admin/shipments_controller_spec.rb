# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ShipmentsController, type: :controller do
  include_context "journey_complete_request"

  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { client }
  let(:json_response) { JSON.parse(response.body) }
  let!(:origin_nexus) {
    FactoryBot.create(:legacy_nexus,
      locode: freight_section.from.locode,
      organization: organization)
  }
  let!(:destination_nexus) {
    FactoryBot.create(:legacy_nexus,
      locode: freight_section.to.locode,
      organization: organization)
  }
  let(:route_sections) { [freight_section] }
  let(:line_items) { freight_line_items_with_cargo }

  before do
    Organizations.current_id = organization.id
    breakdown
    append_token_header
  end

  describe "GET #index" do
    it "returns an http status of success" do
      get :index, params: {organization_id: organization}

      expect(response_data["quoted"].map { |res| res["id"] }).to match([result.id])
    end

    context "when a user has been deleted" do
      before do
        user.destroy
      end

      it "returns an http status of success" do
        get :index, params: {organization_id: organization}

        expect(response).to have_http_status(:success)
      end
    end

    context "when a user is nil" do
      before do
        query.update(client_id: nil)
      end

      it "returns an http status of success" do
        get :index, params: {organization_id: organization.id}

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json.dig(:data, :quoted).pluck(:id)).to include(result.id)
        end
      end
    end

    context "when a user id is given" do
      it "returns an http status of success" do
        get :index, params: {organization_id: organization.id, target_user_id: query.client_id}

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json.dig(:data, :quoted).pluck(:id)).to include(result.id)
        end
      end
    end

    context "when a hub_type is given" do
      it "returns an http status of success" do
        get :index, params: {organization_id: organization.id, hub_type: "ocean"}

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json.dig(:data, :quoted).pluck(:id)).to include(result.id)
        end
      end
    end

    context "when a origin_nexus is given" do
      let(:nexus) { FactoryBot.create(:legacy_nexus, locode: origin_locode) }

      it "returns an http status of success" do
        get :index, params: {organization_id: organization.id, origin_nexus: nexus.id}

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json.dig(:data, :quoted).pluck(:id)).to include(result.id)
        end
      end
    end

    context "when a destination_nexus is given" do
      let(:nexus) { FactoryBot.create(:legacy_nexus, locode: destination_locode) }

      it "returns an http status of success" do
        get :index, params: {organization_id: organization.id, destination_nexus: nexus.id}

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json.dig(:data, :quoted).pluck(:id)).to include(result.id)
        end
      end
    end
  end

  describe "GET #search_shipments" do
    it "returns the matching shipments for the guest user" do
      get :search_shipments, params: {target: "requested", query: user.profile.first_name, organization_id: organization.id}

      expected_client_name = "#{user.profile.first_name} #{user.profile.last_name}"
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

    context "when searching via user's company name/Agency" do
      it "returns matching shipments with users matching the company name in query" do
        get :search_shipments, params: {
          target: "requested", query: user.profile.company_name, organization_id: organization.id
        }
        expect(json.dig(:data, :shipments).first[:id]).to eq(result.id)
      end
    end
  end

  describe "GET #show" do
    context "with charge breakdowns" do
      before do
        get :show, params: {id: result.id, organization_id: organization.id}
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the shipment object sent in the parameters" do
        aggregate_failures do
          expect(json_response["data"]["shipment"]["id"]).to eq(result.id)
          expect(
            json_response["data"].keys
          ).to match_array(
            %w[shipment cargoItems containers aggregatedCargo contacts documents
              addresses cargoItemTypes accountHolder pricingBreakdowns]
          )
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
          aggregate_failures do
            expect(json_response["data"]["containers"]).to be_present
          end
        end
      end

      context "when aggregated" do
        let(:cargo_unit_params) do
          [
            {
              cargo_class: "aggregated_lcl",
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
          aggregate_failures do
            expect(json_response["data"]["aggregatedCargo"]).to be_present
          end
        end
      end
    end

    context "without charge breakdowns" do
      before do
        get :show, params: {id: result.id, organization_id: organization.id}
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the shipment object sent in the parameters" do
        aggregate_failures do
          expect(json_response["data"]["shipment"]["id"]).to eq(result.id)
          expect(
            json_response["data"].keys
          ).to match_array(%w[shipment cargoItems containers aggregatedCargo contacts
            documents addresses cargoItemTypes accountHolder pricingBreakdowns])
        end
      end
    end
  end

  describe "GET #delta_page_handler" do
    it "returns shipments matching the target in params" do
      get :delta_page_handler, params: {target: "quoted", organization_id: organization.id}

      expect(json_response.dig("data", "shipments").count).to eq(1)
    end
  end
end
