# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentService::TruckingWriter do
  context 'class methods' do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, organization: organization) }
    let(:args) { { hub_id: hub.id, organization_id: organization.id } }
    let(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '30001') }
    let!(:target) { FactoryBot.create(:trucking_trucking, hub: hub, location: trucking_location) }

    describe '.consecutive_arrays' do
      it 'returns the correct alphanumeric range' do
        data = %w(AB12 AB13 AB14 AB15 AB16).map { |code| { city_name: code, country_code: 'UK' } }
        result = described_class.new(args).consecutive_arrays(data)
        expect(result).to eq([{ city_name: 'AB12 - AB16', country_code: 'UK' }])
      end
      it 'returns the correct numeric range' do
        data = %w(0012 0013 0014 0015 0016).map { |code| { city_name: code, country_code: 'UK' } }
        result = described_class.new(args).consecutive_arrays(data)
        expect(result).to eq([{ city_name: '0012 - 0016', country_code: 'UK' }])
      end
      it 'returns the correct two numeric range' do
        data = %w(0012 0013 0014 0025 0026 0027).map { |code| { city_name: code, country_code: 'UK' } }
        result = described_class.new(args).consecutive_arrays(data)
        expect(result).to eq([{ city_name: '0012 - 0027', country_code: 'UK' }])
      end
      it 'returns the correct two numeric range' do
        data = %w(AB12 AB13 AB14 AB25 AB26 AB27).map { |code| { city_name: code, country_code: 'UK' } }
        result = described_class.new(args).consecutive_arrays(data)
        expect(result).to eq([{ city_name: 'AB12 - AB27', country_code: 'UK' }])
      end
    end
  end
end
