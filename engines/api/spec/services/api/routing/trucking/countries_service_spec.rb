# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Routing::Trucking::CountriesService, type: :service do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let!(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:location_1) { FactoryBot.create(:zipcode_location, zipcode: "00001", country_code: "SE") }
  let(:location_2) { FactoryBot.create(:zipcode_location, zipcode: "00002", country_code: "SE") }
  let(:results) { described_class.new(target: :destination, tenant: tenant, load_type: "cargo_item").perform }

  describe ".perform" do
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
    let(:origin_hub) { itinerary.hubs.find_by(name: "Gothenburg Port") }
    let(:destination_hub) { itinerary.hubs.find_by(name: "Shanghai Port") }

    before do
      FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
      FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: origin_hub, location: location_1)
      FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: origin_hub, location: location_2)

      FactoryBot.create(:felixstowe_shanghai_itinerary, tenant: legacy_tenant)
    end

    context "with single country trucking" do
      it "renders the list correct list of countries" do
        expect(results.pluck(:code)).to match_array(["SE"])
      end
    end

    context "with cross country trucking" do
      let(:location_2) { FactoryBot.create(:zipcode_location, zipcode: "00002", country_code: "DE") }

      before do
        FactoryBot.create(:legacy_country, code: "DE", name: "Germany")
      end

      it "renders the list correct list of countries" do
        expect(results.pluck(:code)).to match_array(["DE", "SE"])
      end
    end
  end
end
