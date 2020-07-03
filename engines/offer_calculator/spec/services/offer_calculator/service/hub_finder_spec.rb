# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::HubFinder do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let!(:common_trucking) { FactoryBot.create(:trucking_trucking, organization: organization, hub: origin_hub, location: trucking_location) }
  let(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '43813') }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      organization: organization,
                      user: user,
                      trip: nil,
                      origin_hub: nil,
                      destination_hub: nil,
                      trucking: {
                        'pre_carriage': {
                          'address_id': address.id,
                          'truck_type': 'default',
                          'trucking_time_in_seconds': 145_688
                        }
                      },
                      destination_nexus_id: destination_hub.nexus_id,
                      desired_start_date: Date.today + 4.days,
                      cargo_items: [FactoryBot.create(:legacy_cargo_item)],
                      itinerary: itinerary,
                      has_pre_carriage: true)
  end
  before do
    ::Organizations.current_id = organization.id

    FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :zipcode)
  end

  context 'class methods' do
    describe '.perform', :vcr do
      it 'returns the correct hub ids' do
        results = described_class.new(shipment: shipment).perform

        expect(results[:origin]).to eq([origin_hub])
        expect(results[:destination]).to eq([destination_hub])
      end
    end
  end
end
