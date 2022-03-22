# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ChargesController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end

    include_context "journey_pdf_setup"

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:params) { { result_id: result.id, organization_id: organization.id } }
    let(:line_items) { freight_line_items_with_cargo }
    let(:sections) { [freight_section] }

    describe "GET #index" do
      it "successfuly returns the LineItems for the given Result" do
        get :index, params: params, as: :json
        expect(response_data.pluck("id")).to match_array(line_items.pluck(:id))
      end

      context "when a custom currency is supplied " do
        it "returns the LineItems for the given Result, with their totals converted to the desired curency", :aggregate_failures do
          get :index, params: params.merge(currency: "EUR"), as: :json

          expect(response_data.map { |datum| datum.dig("attributes", "value", "currency") }).to eq(["EUR"])
          expect(response_data.map { |datum| datum.dig("attributes", "unitPrice", "currency") }).to eq(["EUR"])
        end
      end
    end
  end
end
