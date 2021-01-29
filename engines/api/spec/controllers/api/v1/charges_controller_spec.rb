# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::ChargesController, type: :controller do
    routes { Engine.routes }
    include_context "journey_pdf_setup"

    before do
      request.headers["Authorization"] = token_header
      freight_line_items_with_cargo
      Treasury::ExchangeRate.create(from: "USD",
                                    to: "EUR", rate: 1.3,
                                    created_at: result.created_at - 30.seconds)
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "GET #show" do
      let(:params) { {organization_id: organization.id, quotation_id: query.id, id: result.id} }

      it "renders the charges successfully" do
        get :show, params: params

        expect(response_data.dig("id")).to eq(result.id)
      end
    end
  end
end
