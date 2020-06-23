# frozen_string_literal: true

require "rails_helper"

RSpec.describe TruckingCounterpartsController, type: :controller do
  let!(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:location_1) { FactoryBot.create(:zipcode_location, zipcode: "00001", country_code: "SE") }
  let(:location_2) { FactoryBot.create(:zipcode_location, zipcode: "00002", country_code: "SE") }
  let(:response_body) { JSON.parse(response.body) }
  let(:data) { response_body["data"] }

  describe "GET #index" do
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }

    before do
      allow(controller).to receive(:current_tenant).and_return(legacy_tenant)
      FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
      FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, query_type: :location)
      FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: origin_hub, location: location_1)
      FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: origin_hub, location: location_2)

      FactoryBot.create(:felixstowe_shanghai_itinerary, tenant: legacy_tenant)
    end

    context "with single country trucking" do
      it "renders the list correct list of countries" do
        get :index, params: {tenant_id: tenant.id, load_type: "cargo_item", target: "destination"}, as: :json

        expect(data).to match_array(["SE"])
      end
    end

    context "with cross country trucking" do
      let(:location_2) { FactoryBot.create(:zipcode_location, zipcode: "00002", country_code: "DE") }

      before do
        FactoryBot.create(:legacy_country, code: "DE", name: "Germany")
      end

      it "renders the list correct list of countries" do
        get :index, params: {tenant_id: tenant.id, load_type: "cargo_item", target: "destination"}, as: :json

        expect(data).to match_array(["SE", "DE"])
      end
    end
  end
end
