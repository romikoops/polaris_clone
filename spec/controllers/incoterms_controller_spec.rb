# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IncotermsController, type: :controller do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }

  describe 'GET #index' do
    it 'returns an http status of success' do
      get :index, params: { tenant_id: tenant.id }
      expect(response).to have_http_status(:success)
    end
  end
end
