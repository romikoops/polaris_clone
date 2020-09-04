# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Routing::Trucking::CounterpartService, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization_id: organization.id) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:user) { FactoryBot.create(:organizations_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', organization: organization) }
  let(:origin_location) do
    FactoryBot.create(:locations_location,
                      bounds: FactoryBot.build(:legacy_bounds, lat: origin_hub.latitude, lng: origin_hub.longitude, delta: 0.4),
                      country_code: 'se')
  end
  let(:destination_location) do
    FactoryBot.create(:locations_location,
                      bounds: FactoryBot.build(:legacy_bounds, lat: destination_hub.latitude, lng: destination_hub.longitude, delta: 0.4),
                      country_code: 'cn')
  end
  let(:origin_trucking_location) { FactoryBot.create(:trucking_location, location: origin_location, country_code: 'SE') }
  let(:destination_trucking_location) { FactoryBot.create(:trucking_location, location: destination_location, country_code: 'CN') }
  let(:wrong_lat) { 10.00 }
  let(:wrong_lng) { 60.50 }
  let(:trucking_service) { described_class.new(organization: organization, arguments: params, target: target) }
  let!(:origin_hub_availability) { FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location) }
  let!(:destination_hub_availability) { FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, custom_truck_type: 'default2', query_type: :location) }
  let(:coordinates) { { lat: lat, lng: lng } }
  let(:coordinate_trucking_details) { Api::Routing::Trucking::DetailsService.new(coordinates: coordinates, nexus_id: nil, load_type: 'cargo_item') }
  let(:destination_nexus_trucking_details) { Api::Routing::Trucking::DetailsService.new(coordinates: nil, nexus_id: destination_hub.nexus_id, load_type: 'cargo_item') }
  let(:origin_nexus_trucking_details) { Api::Routing::Trucking::DetailsService.new(coordinates: nil, nexus_id: origin_hub.nexus_id, load_type: 'cargo_item') }
  let(:default_args) { { organization: organization, target: target } }
  let(:group_client) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:group) {
    FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: group_client, group: tapped_group)
    end
  }

  before do
    Geocoder::Lookup::Test.add_stub([wrong_lat, wrong_lng], [
                                      'address_components' => [{ 'types' => ['premise'] }],
                                      'address' => 'Helsingborg, Sweden',
                                      'city' => 'Gothenburg',
                                      'country' => 'Sweden',
                                      'country_code' => 'SE',
                                      'postal_code' => '43822'
                                    ])
    Geocoder::Lookup::Test.add_stub([origin_hub.latitude, origin_hub.longitude], [
                                      'address_components' => [{ 'types' => ['premise'] }],
                                      'address' => 'Göteborg, Sweden',
                                      'city' => 'Gothenburg',
                                      'country' => 'Sweden',
                                      'country_code' => 'SE',
                                      'postal_code' => '43813'
                                    ])
    Geocoder::Lookup::Test.add_stub([destination_hub.latitude, destination_hub.longitude], [
                                      'address_components' => [{ 'types' => ['premise'] }],
                                      'address' => 'Shanghai, China',
                                      'city' => 'Shanghai',
                                      'country' => 'China',
                                      'country_code' => 'CN',
                                      'postal_code' => '210001'
                                    ])
  end

  context 'when not limited to groups' do
    before do
      FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: origin_hub, location: origin_trucking_location)
      FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: destination_hub, carriage: 'on', location: destination_trucking_location)
    end

    describe '.counterpart_availabilities (origin)' do
      let(:lat) { origin_hub.latitude }
      let(:lng) { origin_hub.longitude }
      let(:target) { :origin }

      context 'when trucking is available with lat lng args' do
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it 'returns available trucking options and country codes' do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to match_array([destination_hub_availability.truck_type])
            expect(data[:countryCodes]).to eq(['cn'])
          end
        end
      end

      context 'when trucking is available with nexus_id args' do
        let(:args) { default_args.merge(trucking_details: origin_nexus_trucking_details) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it 'returns available trucking options and country codes' do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to match_array([destination_hub_availability.truck_type])
            expect(data[:countryCodes]).to eq(['cn'])
          end
        end
      end
    end

    describe '.counterpart_availabilities (dest)' do
      let(:lat) { destination_hub.latitude }
      let(:lng) { destination_hub.longitude }
      let(:target) { :destination }

      context 'when trucking is available with lat lng args' do
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it 'returns available trucking options' do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to eq([origin_hub_availability.truck_type])
            expect(data[:countryCodes]).to eq(['se'])
          end
        end
      end

      context 'when trucking is available with nexus_id args' do
        let(:args) { default_args.merge(trucking_details: destination_nexus_trucking_details) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it 'returns available trucking options and country codes' do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to eq([origin_hub_availability.truck_type])
            expect(data[:countryCodes]).to eq(['se'])
          end
        end
      end
    end
  end

  context 'when limited by groups' do
    before do
      FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: origin_hub, location: origin_trucking_location, group: group)
      FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: destination_hub, carriage: 'on', location: destination_trucking_location, group: group)
    end

    describe '.counterpart_availabilities (dest)' do
      let(:lat) { destination_hub.latitude }
      let(:lng) { destination_hub.longitude }
      let(:target) { :destination }

      context 'when trucking is available for a group' do
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details, user: group_client) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it 'returns available trucking options' do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to eq([origin_hub_availability.truck_type])
          end
        end
      end

      context 'when trucking is not available for a group' do
        let(:no_group_client) { FactoryBot.create(:organizations_user, organization: organization) }
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details, user: no_group_client) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it 'returns available trucking options' do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq false
          end
        end
      end
    end

    describe '.counterpart_availabilities (origin)' do
      let(:lat) { origin_hub.latitude }
      let(:lng) { origin_hub.longitude }
      let(:target) { :origin }

      context 'when trucking is available for a group' do
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details, user: group_client) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it 'returns available trucking options' do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to eq([destination_hub_availability.truck_type])
          end
        end
      end

      context 'when trucking is not available for a group' do
        let(:no_group_client) { FactoryBot.create(:organizations_user, organization: organization) }
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details, user: no_group_client) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it 'returns available trucking options' do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq false
          end
        end
      end
    end
  end
end
