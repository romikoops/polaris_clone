# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  describe 'GET #download_url' do
    let(:user) { create(:user) }
    let(:document) { create(:document_with_file) }

    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'returns http success with the file url' do
      get :download_url, params: { tenant_id: user.tenant_id, document_id: document.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json.dig('data', 'url')).to include('http://test.host/rails/active_storage/blobs')
      end
    end
  end
end
