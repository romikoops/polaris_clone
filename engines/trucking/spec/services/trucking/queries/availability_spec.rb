# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trucking::Queries::Availability do
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
      let(:country_code) { 'SE' }

      let(:address) do
        FactoryBot.create(:legacy_address, zip_code: zipcode, latitude: latitude, longitude: longitude)
      end
      context 'basic tests' do
        it 'raises an ArgumentError if no tenant_id is provided' do
          expect do
            described_class.new(
              load_type: load_type, zipcode: zipcode, carriage: carriage, country_code: country_code
            ).perform
          end.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if no carriage is provided' do
          expect do
            described_class.new(
              klass: ::Trucking::Trucking, tenant_id: tenant.id, zipcode: zipcode, load_type: load_type, country_code: country_code
            ).perform
          end.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if no country_code is provided' do
          expect do
            described_class.new(
              klass: ::Trucking::Trucking, tenant_id: tenant.id, zipcode: zipcode, load_type: load_type, carriage: carriage
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

      context 'zipcode identifier' do
        let!(:trucking_trucking_zipcode) do
          FactoryBot.create(:trucking_trucking,
                            tenant: tenant,
                            hub: hub,
                            location: trucking_location_zipcode)
        end

        it 'finds the correct trucking_rate with avulsed address filters' do
          trucking_rates = described_class.new(
            klass: ::Trucking::Trucking, tenant_id: tenant.id, load_type: load_type,
            carriage: carriage, country_code: country_code,
            zipcode: zipcode, order_by: 'user_id'
          ).perform

          expect(trucking_rates).to match([trucking_trucking_zipcode])
        end

        it 'finds the correct trucking_rate with address object filter' do
          trucking_rates = described_class.new(
            klass: ::Trucking::Trucking, tenant_id: tenant.id, load_type: load_type,
            carriage: carriage, country_code: country_code,
            address: address, order_by: 'user_id'
          ).perform

          expect(trucking_rates).to match([trucking_trucking_zipcode])
        end

        it 'finds the correct trucking_rate with cargo_class filter' do
          trucking_rates = described_class.new(
            klass: ::Trucking::Trucking, tenant_id: tenant.id, load_type: load_type,
            carriage: carriage, country_code: country_code,
            address: address, cargo_classes: ['lcl'], order_by: 'user_id'
          ).perform

          expect(trucking_rates).to match([trucking_trucking_zipcode])
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

      context 'NL postal code identifier' do
        let!(:nl_trucking_trucking_zipcode) do
          FactoryBot.create(:trucking_trucking,
                            tenant: tenant,
                            hub: hub,
                            location: FactoryBot.create(:trucking_location, country_code: 'NL', zipcode: '1802'))
        end
        let(:nl_address) { FactoryBot.create(:legacy_address, zip_code: '1802 PT', country: FactoryBot.create(:legacy_country, code: 'NL')) }
        it 'finds the correct trucking_rate with avulsed address filters' do
          trucking_rates = described_class.new(
            klass: ::Trucking::Trucking, tenant_id: tenant.id, load_type: load_type,
            carriage: carriage, country_code: 'NL',
            zipcode: '1802 PT', order_by: 'user_id'
          ).perform

          expect(trucking_rates).to match([nl_trucking_trucking_zipcode])
        end

        it 'finds the correct trucking_rate with address' do
          trucking_rates = described_class.new(
            klass: ::Trucking::Trucking, tenant_id: tenant.id, load_type: load_type,
            carriage: carriage, address: nl_address, order_by: 'user_id'
          ).perform

          expect(trucking_rates).to match([nl_trucking_trucking_zipcode])
        end

      end

      context 'geometry identifier' do
        let!(:trucking_trucking_geometry) do
          FactoryBot.create(:trucking_trucking,
                            hub: hub,
                            tenant: tenant,
                            location: trucking_location_geometry)
        end

        it 'finds the correct trucking_rate with avulsed address filters' do
          trucking_rates = described_class.new(
            klass: ::Trucking::Trucking, tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            latitude: latitude,   longitude: longitude, order_by: 'user_id'
          ).perform

          expect(trucking_rates).to match([trucking_trucking_geometry])
        end

        it 'finds the correct trucking_rate with address object filter' do
          trucking_rates = described_class.new(
            klass: ::Trucking::Trucking, tenant_id: tenant.id, load_type: load_type,
            carriage: carriage, country_code: country_code,
            address: address, order_by: 'user_id'
          ).perform

          expect(trucking_rates).to match([trucking_trucking_geometry])
        end

        it 'finds the correct trucking_rate with cargo_class filter' do
          trucking_rates = described_class.new(
            klass: ::Trucking::Trucking, tenant_id: tenant.id, load_type: load_type,
            carriage: carriage, country_code: country_code,
            address: address, cargo_classes: ['lcl'], order_by: 'user_id'
          ).perform

          expect(trucking_rates).to match([trucking_trucking_geometry])
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
