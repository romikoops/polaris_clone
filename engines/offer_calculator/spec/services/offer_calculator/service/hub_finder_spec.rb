# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::HubFinder do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:request) { FactoryBot.build(:offer_calculator_request, client: user, params: request_params, organization: organization) }
  let(:request_params) {
    FactoryBot.build(:journey_request_params,
      :lcl,
      pickup_address: address,
      destination_hub: destination_hub)
  }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let!(:common_trucking) do
    FactoryBot.create(:trucking_trucking,
      organization: organization,
      hub: origin_hub,
      location: trucking_location,
      group_id: group_id)
  end
  let(:trucking_location) { FactoryBot.create(:trucking_location, :zipcode, data: "43813", country: address.country) }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: user, group: tapped_group)
    end
  end
  let(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:group_id) { default_group.id }

  before do
    ::Organizations.current_id = organization.id
    allow(request).to receive(:has_on_carriage?).and_return(false)
    allow(request).to receive(:pickup_address).and_return(address)
    FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :zipcode)
  end

  describe ".perform", :vcr do
    context "with pickup and no delivery" do
      it "returns the correct hub ids" do
        results = described_class.new(request: request).perform

        expect(results[:origin]).to eq([origin_hub])
        expect(results[:destination]).to eq([destination_hub])
      end
    end

    context "with pickup and no delivery and group only truckings" do
      let(:group_id) { group.id }

      it "returns the correct hub ids" do
        results = described_class.new(request: request).perform

        expect(results[:origin]).to eq([origin_hub])
        expect(results[:destination]).to eq([destination_hub])
      end
    end
  end
end
