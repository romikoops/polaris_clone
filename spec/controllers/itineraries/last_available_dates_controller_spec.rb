# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Itineraries::LastAvailableDatesController do
  describe 'GET #show' do
    let(:user) { create(:user) }
    let!(:country) { create(:legacy_country, code: 'DE', name: 'Germany') }
    let(:tenant_vehicle) { create(:legacy_tenant_vehicle, tenant: user.tenant) }
    let(:itineraries) do
      [
        create(:gothenburg_shanghai_itinerary, tenant: user.tenant),
        create(:shanghai_gothenburg_itinerary, tenant: user.tenant)
      ]
    end
    let!(:trips) do
      itineraries.flat_map do |itinerary|
        (1...10).map do |i|
          closing = Date.today + (2 * i).days
          create(:legacy_trip,
                 itinerary: itinerary,
                 tenant_vehicle: tenant_vehicle,
                 closing_date: closing,
                 start_date: closing + 4.days,
                 end_date: closing + 35.days)
        end
      end
    end

    it 'returns http success, updates the user and send the email' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)

      params = {
        tenant_id: user.tenant_id,
        itinerary_ids: itineraries.pluck(:id).join(','),
        country: 'DE'
      }
      get :show, params: params

      expect(response).to have_http_status(:success)
    end
  end
end
