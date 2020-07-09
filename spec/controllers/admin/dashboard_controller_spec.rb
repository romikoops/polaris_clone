# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:organizations_membership) { FactoryBot.create(:organizations_membership, role: :admin, organization: organization, member: user) }

  describe 'GET #index' do
    before do
      append_token_header
    end

    it 'returns an http status of success' do
      get :index, params: { organization_id: organization }

      expect(response).to have_http_status(:success)
    end

    context "when current organization is missing" do
      before do
        append_token_header
        allow(controller).to receive(:current_organization).and_return(nil)
      end

      it "halts the request and returns a 404" do
        get :index, params: { organization_id: organization }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
