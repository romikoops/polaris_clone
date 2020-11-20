# frozen_string_literal: true

require "rails_helper"

RSpec.describe IncotermsController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  describe "GET #index" do
    it "returns an http status of success" do
      get :index, params: {organization_id: organization.id}
      expect(response).to have_http_status(:success)
    end
  end
end
