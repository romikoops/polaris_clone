# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::VehicleTypesController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }

  before do
    append_token_header
  end

  describe "GET #index" do
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:carrier) { FactoryBot.create(:carrier, name: "MSC") }
    let!(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier, organization: organization) }
    let!(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
    let(:params) { {organization_id: organization.id} }

    before do
      get :index, params: params
    end

    context "without params" do
      it "returns http success" do
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json.dig(:data).length).to eq(2)
        end
      end
    end

    context "with params" do
      before do
        FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
        get :index, params: params
      end

      let(:params) { {organization_id: organization.id, itinerary_id: itinerary.id} }

      it "returns http success" do
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json.dig(:data, 0, :id)).to eq(tenant_vehicle.id)
        end
      end
    end
  end
end
