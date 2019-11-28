# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trucking::Queries::Distance do
  context 'class methods' do
    describe '.perform' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, tenant: tenant) }

      let(:trucking_location_zipcode) { FactoryBot.create(:trucking_location, :zipcode) }
      let(:trucking_location_geometry)  { FactoryBot.create(:trucking_location, :with_location) }
      let(:trucking_location_distance)  { FactoryBot.create(:trucking_location, :distance) }

      let(:zipcode)      { '15211' }
      let(:latitude)     { '57.000000' }
      let(:longitude)    { '11.100000' }
      let(:load_type)    { 'cargo_item' }
      let(:carriage)     { 'pre' }
      let(:distance)     { 10 }
      let(:country_code) { 'SE' }

      let(:address) do
        FactoryBot.create(:legacy_address, zip_code: zipcode, latitude: latitude, longitude: longitude)
      end
      context 'basic tests' do
        it 'raises an ArgumentError if no load_type is provided' do
          expect do
            described_class.new(
              klass: ::Trucking::Trucking, tenant_id: tenant.id, distance: distance, carriage: carriage, country_code: country_code
            ).perform
          end.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if no tenant_id is provided' do
          expect do
            described_class.new(
              load_type: load_type, distance: distance, carriage: carriage, country_code: country_code
            ).perform
          end.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if no carriage is provided' do
          expect do
            described_class.new(
              klass: ::Trucking::Trucking, tenant_id: tenant.id, distance: distance, load_type: load_type, country_code: country_code
            ).perform
          end.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if no country_code is provided' do
          expect do
            described_class.new(
              klass: ::Trucking::Trucking, tenant_id: tenant.id, distance: distance, load_type: load_type, carriage: carriage
            ).perform
          end.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if incorrect keys are provided' do
          expect do
            described_class.new(
              klass: ::Trucking::Trucking, tenant_id: tenant.id
            ).perform
          end.to raise_error(ArgumentError)
        end
      end

      context 'distance identifier' do
        let!(:trucking_trucking_distance) do
          FactoryBot.create(:trucking_trucking,
                            hub: hub,
                            location: trucking_location_distance)
        end

        it 'return empty collection if cargo_class filter does not match any item in db' do
          trucking_rates = described_class.new(
            klass: ::Trucking::Trucking, tenant_id: tenant.id, load_type: load_type,
            carriage: carriage, country_code: country_code,
            address: address, cargo_classes: ['some_string'], order_by: 'user_id'
          ).perform

          expect(trucking_rates).to match([])
        end
      end
    end
  end
end
