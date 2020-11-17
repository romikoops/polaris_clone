# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trucking::Queries::Availability do
  describe '.perform' do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:hub) { FactoryBot.create(:legacy_hub, latitude: latitude, longitude: longitude, organization: organization) }
    let(:group) { FactoryBot.create(:groups_group, organization: organization) }
    let(:trucking_location_zipcode) { FactoryBot.create(:trucking_location, :zipcode) }
    let(:trucking_location_geometry)  { FactoryBot.create(:trucking_location, :with_location) }
    let(:trucking_location_distance)  { FactoryBot.create(:trucking_location, :distance) }

    let(:zipcode)      { '15211' }
    let(:latitude)     { '57.000000' }
    let(:longitude)    { '11.100000' }
    let(:load_type)    { 'cargo_item' }
    let(:carriage)     { 'pre' }
    let(:country_code) { 'SE' }

    let(:address) do
      FactoryBot.create(:legacy_address, zip_code: zipcode, latitude: latitude, longitude: longitude)
    end
    let(:trucking_results) { described_class.new(args).perform }
    let(:query_type) { :zipcode }
    let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
    let(:groups) { [default_group] }

    before do
      FactoryBot.create(:lcl_pre_carriage_availability, hub: hub, query_type: query_type)
    end

    context 'with missing arguments (organization_id)' do
      let(:args) { { load_type: load_type, zipcode: zipcode, carriage: carriage, country_code: country_code } }

      it 'raises an ArgumentError if no organization_id is provided' do
        expect { trucking_results }.to raise_error(ArgumentError)
      end
    end

    context 'with missing arguments (carriage)' do
      let(:args) { { klass: ::Trucking::Trucking, organization_id: organization.id, zipcode: zipcode, load_type: load_type, country_code: country_code } }

      it 'raises an ArgumentError if no carriage is provided' do
        expect { trucking_results }.to raise_error(ArgumentError)
      end
    end

    context 'with missing arguments (wrong keys)' do
      let(:args) { { klass: ::Trucking::Trucking, organization_id: organization.id } }

      it 'raises an ArgumentError if incorrect keys are provided' do
        expect { trucking_results }.to raise_error(ArgumentError)
      end
    end

    context 'with zipcode identifier' do
      let!(:trucking_trucking_zipcode) do
        FactoryBot.create(:trucking_trucking,
                          organization: organization,
                          hub: hub,
                          location: trucking_location_zipcode)
      end

      let(:query_type) { :zipcode }

      it 'finds the correct trucking_rate with avulsed address filters' do
        trucking_rates = described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage, country_code: country_code,
          zipcode: zipcode, groups: groups
        ).perform

        expect(trucking_rates).to match([trucking_trucking_zipcode])
      end

      it 'finds the correct trucking_rate with address object filter' do
        trucking_rates = described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage, country_code: country_code,
          address: address, groups: groups
        ).perform

        expect(trucking_rates).to match([trucking_trucking_zipcode])
      end

      it 'finds the correct trucking_rate with cargo_class filter' do
        trucking_rates = described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage, country_code: country_code,
          address: address, cargo_classes: ['lcl'], groups: groups
        ).perform

        expect(trucking_rates).to match([trucking_trucking_zipcode])
      end

      it 'return empty collection if cargo_class filter does not match any item in db' do
        trucking_rates = described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage, country_code: country_code,
          address: address, cargo_classes: ['some_string'], groups: groups
        ).perform

        expect(trucking_rates).to match([])
      end
    end

    context 'with NL postal code identifier' do
      let(:country) { FactoryBot.create(:country_nl) }
      let!(:nl_trucking_trucking_zipcode) do
        FactoryBot.create(:trucking_trucking,
                          organization: organization,
                          hub: hub,
                          location: FactoryBot.create(:trucking_location, :zipcode, country: country, data: '1802'))
      end
      let(:nl_address) {
        FactoryBot.create(:legacy_address,
          zip_code: '1802 PT',
          country: country)
      }

      it 'finds the correct trucking_rate with avulsed address filters' do
        trucking_rates = described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage, country_code: 'NL',
          zipcode: '1802 PT', groups: groups
        ).perform

        expect(trucking_rates).to match([nl_trucking_trucking_zipcode])
      end

      it 'finds the correct trucking_rate with address' do
        trucking_rates = described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage, address: nl_address, groups: groups
        ).perform

        expect(trucking_rates).to match([nl_trucking_trucking_zipcode])
      end
    end

    context 'with distance identifier' do
      let!(:nl_trucking_trucking_distance) do
        FactoryBot.create(:trucking_trucking,
                          organization: organization,
                          hub: hub,
                          location: distance_location)
      end
      let(:query_type) { :distance }
      let(:country) { FactoryBot.create(:country_nl) }
      let(:nl_address) do
        FactoryBot.create(:legacy_address,
          zip_code: '1802 PT',
          latitude: '57.00001',
          longitude: '11.10001',
          country: country)
      end
      let(:distance_service) do
        described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage, country_code: 'NL',
          address: nl_address, groups: groups
        )
      end
      let(:other_hub) { FactoryBot.create(:legacy_hub, organization: organization) }
      let(:distance_location) { FactoryBot.create(:trucking_location, :distance, country: country, data: 89) }

      before do
        FactoryBot.create(:lcl_pre_carriage_availability, hub: other_hub, query_type: query_type)
        FactoryBot.create(:trucking_location, country: country, distance: nil)
        FactoryBot.create(:trucking_trucking,
                            organization: organization,
                            hub: other_hub,
                            location: distance_location)
        allow(distance_service).to receive(:distance_hubs).and_return([hub])
        allow(::Trucking::GoogleDirections).to receive(:new).and_return(instance_double('Trucking::GoogleDirections', distance_in_km: 89))
      end

      it 'finds the correct trucking_rate by distance' do
        expect(distance_service.perform).to match([nl_trucking_trucking_distance])
      end

      context "with no distance based locations" do
        let(:nl_trucking_trucking_distance) { nil }

        it 'finds no truckings' do
          expect(distance_service.perform).to be_empty
        end
      end
    end

    context 'with geometry identifier' do
      let!(:trucking_trucking_geometry) do
        FactoryBot.create(:trucking_trucking,
                          hub: hub,
                          organization: organization,
                          location: trucking_location_geometry)
      end
      let(:query_type) { :location }

      it 'finds the correct trucking_rate with avulsed address filters' do
        trucking_rates = described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage,   country_code: country_code,
          latitude: latitude,   longitude: longitude, groups: groups
        ).perform

        expect(trucking_rates).to match([trucking_trucking_geometry])
      end

      it 'finds the correct trucking_rate with address object filter' do
        trucking_rates = described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage, country_code: country_code,
          address: address, groups: groups
        ).perform

        expect(trucking_rates).to match([trucking_trucking_geometry])
      end

      it 'finds the correct trucking_rate with cargo_class filter' do
        trucking_rates = described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage, country_code: country_code,
          address: address, cargo_classes: ['lcl'], groups: groups
        ).perform

        expect(trucking_rates).to match([trucking_trucking_geometry])
      end

      it 'return empty collection if cargo_class filter does not match any item in db' do
        trucking_rates = described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage, country_code: country_code,
          address: address, cargo_classes: ['some_string'], groups: groups
        ).perform

        expect(trucking_rates).to match([])
      end
    end
  end
end
