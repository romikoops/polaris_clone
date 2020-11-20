# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContentsController do
  describe "GET #component" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:content) { FactoryBot.create(:legacy_content, organization_id: organization.id) }

    it "returns http success" do
      get :component, params: {organization_id: organization.id, component: content.component}
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json.dig("data", "content", "main", 0, "text")).to eq(content.text)
    end
  end
end
