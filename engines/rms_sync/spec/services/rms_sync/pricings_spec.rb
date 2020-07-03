# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RmsSync::Pricings do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:tenant_vehicles) do
    [
      FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', organization: organization),
      FactoryBot.create(:legacy_tenant_vehicle,
                        name: 'faster',
                        organization: organization,
                        carrier: FactoryBot.build(:legacy_carrier, name: 'MSC'))
    ]
  end
  let!(:currency) { FactoryBot.create(:legacy_currency) }

  describe '.perform' do
    it 'should create a Book, Sheet and Cells' do
      pricings = []
      tenant_vehicles.each do |tv|
        pricings << FactoryBot.create(:lcl_pricing, organization: organization, tenant_vehicle: tv, itinerary: itinerary)
        pricings << FactoryBot.create(:fcl_20_pricing, organization: organization, tenant_vehicle: tv, itinerary: itinerary)
        pricings << FactoryBot.create(:fcl_40_pricing, organization: organization, tenant_vehicle: tv, itinerary: itinerary)
        pricings << FactoryBot.create(:fcl_40_hq_pricing, organization: organization, tenant_vehicle: tv, itinerary: itinerary)
      end
      described_class.new(organization_id: organization.id, sheet_type: :pricings).perform
      expect(RmsData::Book.where(sheet_type: :pricings).length).to eq(1)
      book = RmsData::Book.where(sheet_type: :pricings).first
      expect(RmsData::Sheet.where(book_id: book.id).length).to eq(1)
      sheet = RmsData::Sheet.where(book_id: book.id).first
      expect(RmsData::Cell.where(sheet_id: sheet.id).length).to eq(162)
      expect(sheet.rows.length).to eq(9)
      expect(sheet.header_values).to eq(%w(EFFECTIVE_DATE
                                           EXPIRATION_DATE
                                           ORIGIN
                                           COUNTRY_ORIGIN
                                           DESTINATION
                                           COUNTRY_DESTINATION
                                           MOT
                                           CARRIER
                                           SERVICE_LEVEL
                                           LOAD_TYPE
                                           RATE_BASIS
                                           RANGE_MIN
                                           RANGE_MAX
                                           FEE_CODE
                                           FEE_NAME
                                           CURRENCY
                                           FEE_MIN
                                           FEE))
      first_row = sheet.rows_values.find { |r| r[9] == 'lcl' && r[8] == 'slowly' }
      expect(first_row).to eq([pricings.first.effective_date.to_s,
                               pricings.first.expiration_date.to_s,
                               'Gothenburg',
                               'Sweden',
                               'Shanghai',
                               'China',
                               'ocean',
                               nil,
                               'slowly',
                               'lcl',
                               'PER_WM',
                               nil,
                               nil,
                               'bas',
                               'Basic Ocean Freight',
                               'EUR',
                               '1.0',
                               '25.0'])
    end

    it 'should create multiple rows for range fees' do
      pricing = FactoryBot.create(:lcl_range_pricing, organization: organization, tenant_vehicle: tenant_vehicles.first, itinerary: itinerary)
      described_class.new(organization_id: organization.id, sheet_type: :pricings).perform
      expect(RmsData::Book.where(sheet_type: :pricings).length).to eq(1)
      book = RmsData::Book.where(sheet_type: :pricings).first
      expect(RmsData::Sheet.where(book_id: book.id).length).to eq(1)
      sheet = RmsData::Sheet.where(book_id: book.id).first
      expect(sheet.rows_values).to eq([%w(EFFECTIVE_DATE
                                          EXPIRATION_DATE
                                          ORIGIN
                                          COUNTRY_ORIGIN
                                          DESTINATION
                                          COUNTRY_DESTINATION
                                          MOT
                                          CARRIER
                                          SERVICE_LEVEL
                                          LOAD_TYPE
                                          RATE_BASIS
                                          RANGE_MIN
                                          RANGE_MAX
                                          FEE_CODE
                                          FEE_NAME
                                          CURRENCY
                                          FEE_MIN
                                          FEE),
                                       [pricing.effective_date.to_s,
                                        pricing.expiration_date.to_s,
                                        'Gothenburg',
                                        'Sweden',
                                        'Shanghai',
                                        'China',
                                        'ocean',
                                        nil,
                                        'slowly',
                                        'lcl',
                                        'PER_KG_RANGE',
                                        '0',
                                        '100',
                                        'bas',
                                        'Basic Ocean Freight',
                                        'EUR',
                                        '1.0',
                                        '10'],
                                       [pricing.effective_date.to_s,
                                        pricing.expiration_date.to_s,
                                        'Gothenburg',
                                        'Sweden',
                                        'Shanghai',
                                        'China',
                                        'ocean',
                                        nil,
                                        'slowly',
                                        'lcl',
                                        'PER_KG_RANGE',
                                        '101',
                                        '500',
                                        'bas',
                                        'Basic Ocean Freight',
                                        'EUR',
                                        '1.0',
                                        '8'],
                                       [pricing.effective_date.to_s,
                                        pricing.expiration_date.to_s,
                                        'Gothenburg',
                                        'Sweden',
                                        'Shanghai',
                                        'China',
                                        'ocean',
                                        nil,
                                        'slowly',
                                        'lcl',
                                        'PER_KG_RANGE',
                                        '501',
                                        '1000',
                                        'bas',
                                        'Basic Ocean Freight',
                                        'EUR',
                                        '1.0',
                                        '6']])
    end
  end
end
