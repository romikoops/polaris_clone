# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactsController do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { create(:organizations_user, organization: organization) }
  let!(:contacts) { create_list(:contact, 5, user: user) }

  before do
    append_token_header
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { organization_id: user.organization_id }

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
        get :search_contacts, params: { organization_id: user.organization_id, query: 'Bober' }

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
        get :booking_process, params: { organization_id: user.organization_id, query: 'Bober' }

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

  describe 'POST #create' do
    let(:contact_params) {
      {
        organization_id: user.organization_id,
        new_contact: JSON.generate({
          "firstName": "First Name",
          "lastName": "Last Name",
          "companyName": "Company",
          "phone": "123456789",
          "email": "email@itsmytest.com",
          "street": "brooktorkai",
          "number": "brooktorkai",
          "zipCode": "20457",
          "city": "Hamburg",
          "country": "Germany"
        })
      }
    }

    it 'returns http success' do
      post :create, params: contact_params

      expect(response).to have_http_status(:success)
    end
  end
end
