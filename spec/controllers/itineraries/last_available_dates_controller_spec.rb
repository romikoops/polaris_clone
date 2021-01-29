# frozen_string_literal: true

require "rails_helper"

RSpec.describe Itineraries::LastAvailableDatesController do
  describe "GET #show" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_client, organization: organization) }
    let!(:country) { FactoryBot.create(:legacy_country, code: "DE", name: "Germany") }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
    let(:itineraries) do
      [
        FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization),
        FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization)
      ]
    end
    let!(:trips) do
      itineraries.flat_map do |itinerary|
        (1...10).map do |i|
          closing = Time.zone.today + (2 * i).days
          FactoryBot.create(:legacy_trip,
            itinerary: itinerary,
            tenant_vehicle: tenant_vehicle,
            closing_date: closing,
            start_date: closing + 4.days,
            end_date: closing + 35.days)
        end
      end
    end

    it "returns http success, updates the user and send the email" do
      append_token_header

      params = {
        organization_id: user.organization_id,
        itinerary_ids: itineraries.pluck(:id).join(","),
        country: "DE"
      }
      get :show, params: params

      expect(response).to have_http_status(:success)
    end
  end
end
