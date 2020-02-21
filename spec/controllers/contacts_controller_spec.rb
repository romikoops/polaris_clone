# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactsController do
  let(:user) { create(:user) }
  let!(:contacts) { create_list(:contact, 5, user: user) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { tenant_id: user.tenant.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['success']).to eq true
        expect(json.dig('data', 'numContactPages')).to eq 1
        expect(json.dig('data', 'contacts').map { |c| c['id'] }.sort).to eq contacts.map(&:id).sort
      end
    end
  end

  context 'when searching' do
    let!(:target_contact) { create(:contact, user: user, first_name: 'Bobert') }

    describe 'GET #search_contacts' do
      it 'returns the correct contact' do
        get :search_contacts, params: { tenant_id: user.tenant.id, query: 'Bober' }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          json = JSON.parse(response.body)
          expect(json['success']).to eq true
          expect(json.dig('data', 'numContactPages')).to eq 1
          expect(json.dig('data', 'contacts', 0, 'id')).to eq target_contact.id
        end
      end
    end

    describe 'GET #booking_process' do
      it 'returns the correct contact' do
        get :booking_process, params: { tenant_id: user.tenant.id, query: 'Bober' }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          json = JSON.parse(response.body)
          expect(json['success']).to eq true
          expect(json.dig('data', 'numContactPages')).to eq 1
          expect(json.dig('data', 'contacts', 0, 'contact', 'id')).to eq target_contact.id
        end
      end
    end
  end
end
