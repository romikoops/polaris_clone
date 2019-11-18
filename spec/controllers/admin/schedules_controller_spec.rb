# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SchedulesController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:role) { FactoryBot.create(:legacy_role, name: 'Admin') }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, role: role) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }

  describe 'GET #show' do
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: 'MSC') }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier) }
    let(:closing_date) { Date.today }
    let(:start_date) { Date.today + 4.days }
    let(:end_date) { Date.today + 30.days }
    let!(:trips) do
      (1..10).map do |delta|
        FactoryBot.create(:legacy_trip,
                          itinerary: itinerary,
                          closing_date: closing_date + delta.days,
                          start_date: start_date + delta.days,
                          end_date: end_date + delta.days,
                          tenant_vehicle: tenant_vehicle)
      end
    end
    let(:edit_params) {
      {
        id: itinerary.id,
        tenant_id: user.tenant_id
      }
    }
    it 'returns http success' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      get :show, params: edit_params
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data', 'schedules').length).to eq 10
      expect(json.dig('data', 'schedules', 0, 'carrier')).to eq 'MSC'
      expect(json.dig('data', 'schedules', 0, 'service_level')).to eq 'standard'
    end
  end
end
