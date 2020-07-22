# frozen_string_literal: true

require 'rails_helper'
require 'roo'

RSpec.describe ExcelDataServices::FileWriters::Pricings do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:itinerary) { create(:gothenburg_shanghai_itinerary) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:static_pricing_headers) do
    (described_class::HEADER_COLLECTION::OPTIONAL_PRICING_DYNAMIC_FEE_COLS_NO_RANGES +
       described_class::HEADER_COLLECTION::PRICING_DYNAMIC_FEE_COLS_NO_RANGES)
      .map { |header| header.to_s.upcase }
  end
  let!(:transit_time) { FactoryBot.create(:legacy_transit_time, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }

  context 'when container' do
    before { pricing_row }

    let(:dynamic_pricing_headers) do
      %w[
        BAS
      ]
    end
    let(:pricing_row) do
      [
        itinerary.origin_hub.locode,
        itinerary.destination_hub.locode,
        pricing.group_id,
        Groups::Group.find_by(id: pricing.group_id)&.name,
        pricing.transshipment,
        transit_time.duration,
        nil,
        pricing.effective_date.to_date,
        pricing.expiration_date.to_date,
        nil,
        'Gothenburg',
        'Sweden',
        'Shanghai',
        'China',
        'ocean',
        nil,
        'standard',
        'FCL_20',
        'PER_CONTAINER',
        'EUR',
        250
      ]
    end

    context 'when all pricings are valid' do
      let(:pricing) { create(:fcl_20_pricing, organization: organization, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }
      let(:result) { described_class.write_document(organization: organization, user: user, file_name: 'test.xlsx', options: { mode_of_transport: 'ocean' }) }
      let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
      let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

      describe '.perform' do
        it 'writes all pricings to the sheet' do
          aggregate_failures 'testing sheet values' do
            headers = first_sheet.row(1)
            static_headers = headers[0..-2]
            expect(static_headers).to eq(static_pricing_headers)
            expect(first_sheet.row(2)).to eq(pricing_row)
          end
        end
      end
    end

    context 'when all pricings are valid with attached group' do
      let(:group_id) { create(:groups_group, organization: organization, name: 'TEST').id }
      let(:pricing) { create(:fcl_20_pricing, organization: organization, group_id: group_id, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }
      let(:result) { described_class.write_document(organization: organization, user: user, file_name: 'test.xlsx', options: { mode_of_transport: 'ocean', group_id: group_id }) }
      let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
      let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

      describe '.perform' do
        it 'writes all pricings to the sheet' do
          aggregate_failures 'testing sheet values' do
            headers = first_sheet.row(1)
            static_headers = headers[0..-2]
            dynamic_headers = headers.last(1)
            expect(static_headers).to eq(static_pricing_headers)
            expect(dynamic_headers).to eq(dynamic_pricing_headers)
            expect(first_sheet.row(2)).to eq(pricing_row)
          end
        end
      end
    end
  end

  context 'with cargo_item' do
    let(:dynamic_pricing_headers) do
      %w[
        BAS
      ]
    end

    context 'when all pricings are valid' do
      let(:pricing_row) do
        [
          itinerary.origin_hub.locode,
          itinerary.destination_hub.locode,
          nil,
          nil,
          nil,
          transit_time.duration,
          nil,
          pricing.effective_date.to_date,
          pricing.expiration_date.to_date,
          nil,
          'Gothenburg',
          'Sweden',
          'Shanghai',
          'China',
          'ocean',
          nil,
          'standard',
          'LCL',
          'PER_WM',
          'EUR',
          25
        ]
      end

      let!(:pricing) { create(:lcl_pricing, organization: organization, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }
      let(:result) { described_class.write_document(organization: organization, user: user, file_name: 'test.xlsx', options: { mode_of_transport: 'ocean' }) }
      let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
      let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

      describe '.perform' do
        it 'writes all pricings to the sheet' do
          aggregate_failures 'testing sheet values' do
            headers = first_sheet.row(1)
            static_headers = headers[0..-2]
            dynamic_headers = headers.last(1)
            expect(static_headers).to eq(static_pricing_headers)
            expect(dynamic_headers).to eq(dynamic_pricing_headers)
            expect(first_sheet.row(2)).to eq(pricing_row)
          end
        end
      end
    end

    context 'when some pricings are expired' do
      before do
        create(:lcl_pricing, organization: organization, itinerary: itinerary, tenant_vehicle: tenant_vehicle, expiration_date: Time.zone.now - 10.days, effective_date: Time.zone.now - 30.days)
      end

      let(:pricing_row) do
        [
          itinerary.origin_hub.locode,
          itinerary.destination_hub.locode,
          nil,
          nil,
          nil,
          transit_time.duration,
          nil,
          pricing.effective_date.to_date,
          pricing.expiration_date.to_date,
          nil,
          'Gothenburg',
          'Sweden',
          'Shanghai',
          'China',
          'ocean',
          nil,
          'standard',
          'LCL',
          'PER_WM',
          'EUR',
          25
        ]
      end
      let!(:pricing) { create(:lcl_pricing, organization: organization, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }
      let(:result) { described_class.write_document(organization: organization, user: user, file_name: 'test.xlsx', options: { mode_of_transport: 'ocean' }) }
      let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
      let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

      describe '.perform' do
        it 'writes all valid pricings to the sheet' do
          aggregate_failures 'testing sheet values' do
            expect(first_sheet.row(2)).to eq(pricing_row)
            expect(first_sheet.row(3).compact).to be_empty
          end
        end
      end
    end

    context 'when all pricings are valid with attached group' do
      let(:pricing_headers) do
        (described_class::HEADER_COLLECTION::OPTIONAL_PRICING_ONE_FEE_COL_AND_RANGES +
           described_class::HEADER_COLLECTION::PRICING_ONE_FEE_COL_AND_RANGES).map { |header| header.to_s.upcase }
      end
      let(:group_id) { create(:groups_group, organization: organization, name: 'TEST').id }
      let(:pricing) { create(:pricings_pricing, organization: organization, group_id: group_id, tenant_vehicle: tenant_vehicle, itinerary: itinerary, transshipment: 'ZACPT') }
      let(:pricing_row) do
        [
          itinerary.origin_hub.locode,
          itinerary.destination_hub.locode,
          pricing.group_id,
          Groups::Group.find_by(id: pricing.group_id).name,
          pricing.transshipment,
          transit_time.duration,
          nil,
          pricing.effective_date.to_date,
          pricing.expiration_date.to_date,
          nil,
          'Gothenburg',
          'Sweden',
          'Shanghai',
          'China',
          'ocean',
          nil,
          'standard',
          'LCL',
          'PER_WM',
          0,
          4.9,
          'BAS',
          'Basic Ocean Freight',
          'EUR',
          1,
          8
        ]
      end
      let(:result) { described_class.write_document(organization: organization, user: user, file_name: 'test.xlsx', options: { mode_of_transport: 'ocean', group_id: group_id }) }
      let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
      let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

      before do
        create(:pricings_fee, pricing_id: pricing.id,
                              range: [
                                { min: 0.0, max: 4.9, rate: 8 },
                                { min: 5.0, max: 10, rate: 12 }
                              ],
                              rate_basis: create(:per_wm_rate_basis),
                              rate: 25,
                              charge_category: create(:bas_charge, organization: organization))
      end

      describe '.perform' do
        it 'writes all pricings to the sheet' do
          aggregate_failures 'testing sheet values' do
            expect(first_sheet.row(1)).to eq(pricing_headers)
            expect(first_sheet.row(2)).to eq(pricing_row)
          end
        end
      end
    end
  end
end
