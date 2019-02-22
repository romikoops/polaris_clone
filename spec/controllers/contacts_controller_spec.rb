# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactsController do
  describe 'GET #index' do
    let(:user) { create(:user) }
    let!(:contacts) { create_list(:contact, 5, user: user) }

    it 'returns http success' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)

      get :index, params: { tenant_id: user.tenant.id }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json['success']).to eq true
      expect(json.dig('data', 'numContactPages')).to eq 1
      expect(json.dig('data', 'contacts').map { |c| c['id'] }.sort).to eq contacts.map(&:id).sort
    end
  end
end
