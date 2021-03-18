# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::TendersController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:query) { FactoryBot.build(:journey_query, organization: organization, client: user) }
    let(:result) { FactoryBot.create(:journey_result, query: query) }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:line_item_set) { result.line_item_sets.first }
    let(:optional) { false }
    let(:included) { false }
    let(:line_item) do
      FactoryBot.create(:journey_line_item,
        line_item_set: line_item_set,
        units: 3,
        total: Money.new(9000, "EUR"),
        unit_price: Money.new(3000, "EUR"),
        optional: optional,
        exchange_rate: 1,
        included: included)
    end
    let(:new_line_item_set) { Journey::LineItemSet.where(result: result).where.not(id: line_item_set).first }
    let(:updated_line_item) { new_line_item_set.line_items.find { |li| li.fee_code == line_item.fee_code } }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "PATCH #update" do
      let(:params) { {organization_id: organization.id, line_item_id: line_item.id, id: result.id, value: 50} }

      it "renders the charges successfully", :aggregate_failures do
        patch :update, params: params

        expect(response_data.dig("id")).to eq(result.id)
        expect(response_data.dig("attributes", "charges", 0, "originalValue", "amount")).to eq(
          line_item.total.amount.to_s
        )
        expect(response_data.dig("attributes", "charges", 0, "value", "amount")).to eq("50.0")
      end
    end
  end
end
