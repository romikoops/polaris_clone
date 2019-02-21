# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentsController do
  describe 'GET #component' do
    let(:tenant) { create(:tenant) }
    let!(:content) { create(:content, tenant_id: tenant.id) }

    it 'returns http success' do
      get :component, params: { tenant_id: tenant.id, component: content.component }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json.dig('data', 'content', 'main', 0, 'text')).to eq(content.text)
    end
  end
end
