# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::TendersController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
      FactoryBot.create(:users_membership, organization: organization, user: user)
      FactoryBot.create(:legacy_charge_categories, code: "cargo", organization: organization)
    end

    let(:user) { FactoryBot.create(:users_user) }
    let(:client) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:query) { FactoryBot.build(:journey_query, organization: organization, client: client) }
    let(:result) { FactoryBot.build(:journey_result, query: query, line_item_set_count: 0) }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:line_item_set) { FactoryBot.build(:journey_line_item_set, result: result, line_item_count: 0) }
    let!(:line_item) do
      FactoryBot.create(:journey_line_item,
        line_item_set: line_item_set,
        route_section: result.route_sections.first,
        units: 3,
        total: Money.new(9000, "EUR"),
        unit_price: Money.new(3000, "EUR"),
        exchange_rate: 1)
    end
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "PATCH #update" do
      let(:params) { { organization_id: organization.id, line_item_id: line_item.id, id: result.id, value: 50 } }

      it "renders the charges successfully", :aggregate_failures do
        patch :update, params: params
        expect(response_data["id"]).to eq(result.id)
        expect(response_data.dig("attributes", "charges", 0, "originalValue", "amount")).to eq(line_item.total.amount.to_s)
        expect(response_data.dig("attributes", "charges", 0, "value", "amount")).to eq("50.0")
      end
    end
  end
end
