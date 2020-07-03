# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  let(:org_user) { FactoryBot.create(:organizations_user) }
  let(:user) { org_user.becomes(Authentication::User) }
  let(:document) { FactoryBot.create(:legacy_file, :with_file, user: org_user) }

  before do
    append_token_header
  end

  describe 'GET #download_url' do
    it 'returns http success with the file url' do
      get :download_url, params: { organization_id: user.organization_id, document_id: document.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json.dig('data', 'url')).to include('http://test.host/rails/active_storage/blobs')
      end
    end
  end

  describe 'GET #delete' do
    it 'returns http success and deletes the file' do
      get :delete, params: { organization_id: user.organization_id, document_id: document.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(Legacy::File.find_by(id: document.id)).to be_nil
      end
    end
  end
end
