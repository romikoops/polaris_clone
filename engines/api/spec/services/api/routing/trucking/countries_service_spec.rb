# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Routing::Trucking::CountriesService, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:location_1) { FactoryBot.create(:zipcode_location, zipcode: "00001", country_code: "SE") }
  let(:location_2) { FactoryBot.create(:zipcode_location, zipcode: "00002", country_code: "SE") }
  let(:results) { described_class.new(target: :destination, organization: organization, load_type: "cargo_item").perform }

  describe ".perform" do
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }

    before do
      FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
      FactoryBot.create(:trucking_trucking, organization: organization, hub: origin_hub, location: location_1)
      FactoryBot.create(:trucking_trucking, organization: organization, hub: origin_hub, location: location_2)

      FactoryBot.create(:felixstowe_shanghai_itinerary, organization: organization)
    end

    context "with single country trucking" do
      it "renders the list correct list of countries" do
        expect(results.pluck(:code)).to match_array(["SE"])
      end
    end

    context "with cross country trucking" do
      let(:country) { FactoryBot.create(:legacy_country, code: "DE", name: "Germany") }

      before do
        FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location, country: country)
      end

      it "renders the list correct list of countries" do
        expect(results.pluck(:code)).to match_array(["DE", "SE"])
      end
    end
  end
end
