# frozen_string_literal: true

require 'rails_helper'
require 'roo'

RSpec.describe ExcelDataServices::FileWriters::Pricings do
  let(:tenant) { FactoryBot.create(:tenant) }
  let!(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:itinerary) { create(:gothenburg_shanghai_itinerary) }
  let!(:trips) { create(:trip, itinerary_id: itinerary.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:static_pricing_headers) do
    (described_class::HEADER_COLLECTION::OPTIONAL_PRICING_DYNAMIC_FEE_COLS_NO_RANGES +
       described_class::HEADER_COLLECTION::PRICING_DYNAMIC_FEE_COLS_NO_RANGES)
      .map { |header| header.to_s.upcase }
  end

  context 'container' do
    let(:dynamic_pricing_headers) do
      %w[
        TRANSIT_TIME
        BAS
      ]
    end
    let(:pricing_row) do
      [
        pricing.respond_to?(:group_id) ? pricing.group_id : nil,
        pricing.respond_to?(:group_id) ? Tenants::Group.find_by(id: pricing.group_id).name : nil,
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
        14,
        250
      ]
    end

    context 'when all pricings are valid' do
      let!(:charge_category) { create(:charge_category, :bas, tenant: tenant) }
      let!(:pricing) { create(:legacy_fcl_20_pricing, tenant: tenant, itinerary: itinerary) }
      let(:result) { described_class.write_document(tenant: tenant, user: tenants_user, file_name: 'test.xlsx', sandbox: nil, options: { mode_of_transport: 'ocean' }) }
      let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
      let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

      describe '.perform' do
        it 'writes all pricings to the sheet' do
          aggregate_failures 'testing sheet values' do
            headers = first_sheet.row(1)
            static_headers = headers[0..-3]
            dynamic_headers = headers[-2..-1]
            expect(static_headers).to eq(static_pricing_headers)
            expect(first_sheet.row(2)).to eq(pricing_row)
          end
        end
      end
    end

    context 'when all pricings are valid with attached group' do
      before do
        create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true })
      end

      let(:group_id) { create(:tenants_group, tenant: tenants_tenant, name: 'TEST').id }
      let!(:pricing) { create(:fcl_20_pricing, tenant: tenant, group_id: group_id, itinerary: itinerary) }
      let(:result) { described_class.write_document(tenant: tenant, user: tenants_user, file_name: 'test.xlsx', sandbox: nil, options: { mode_of_transport: 'ocean', group_id: group_id }) }
      let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
      let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

      describe '.perform' do
        it 'writes all pricings to the sheet' do
          aggregate_failures 'testing sheet values' do
            headers = first_sheet.row(1)
            static_headers = headers[0..-3]
            dynamic_headers = headers.last(2)
            expect(static_headers).to eq(static_pricing_headers)
            expect(dynamic_headers).to eq(dynamic_pricing_headers)
            expect(first_sheet.row(2)).to eq(pricing_row)
          end
        end
      end
    end
  end

  context 'cargo_item' do
    let(:dynamic_pricing_headers) do
      %w[
        TRANSIT_TIME
        BAS
      ]
    end

    context 'when all pricings are valid' do
      let(:pricing_row) do
        [
          nil,
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
          14,
          25
        ]
      end
      let!(:charge_category) { create(:charge_category, :bas, tenant: tenant) }
      let!(:pricing) { create(:legacy_lcl_pricing, tenant: tenant, itinerary: itinerary) }
      let(:result) { described_class.write_document(tenant: tenant, user: tenants_user, file_name: 'test.xlsx', sandbox: nil, options: { mode_of_transport: 'ocean' }) }
      let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
      let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

      describe '.perform' do
        it 'writes all pricings to the sheet' do
          aggregate_failures 'testing sheet values' do
            headers = first_sheet.row(1)
            static_headers = headers[0..-3]
            dynamic_headers = headers.last(2)
            expect(static_headers).to eq(static_pricing_headers)
            expect(dynamic_headers).to eq(dynamic_pricing_headers)
            expect(first_sheet.row(2)).to eq(pricing_row)
          end
        end
      end
    end

    context 'when some pricings are expired' do
      let(:pricing_row) do
        [
          nil,
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
          14,
          25
        ]
      end
      let(:transport_category) { create(:ocean_lcl) }
      let!(:pricing) { create(:legacy_lcl_pricing, tenant: tenant, itinerary: itinerary, transport_category: transport_category) }
      let(:result) { described_class.write_document(tenant: tenant, user: tenants_user, file_name: 'test.xlsx', sandbox: nil, options: { mode_of_transport: 'ocean' }) }
      let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
      let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

      before { create(:legacy_lcl_pricing, tenant: tenant, itinerary: itinerary, expiration_date: Time.zone.now - 10.days, effective_date: Time.zone.now - 30.days, transport_category: transport_category) }

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
      before do
        create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true })
      end

      let(:pricing_headers) do
        (described_class::HEADER_COLLECTION::OPTIONAL_PRICING_ONE_COL_FEE_AND_RANGES +
           described_class::HEADER_COLLECTION::PRICING_ONE_COL_FEE_AND_RANGES).map { |header| header.to_s.upcase }
      end
      let(:pricing_row) do
        [
          pricing.group_id,
          Tenants::Group.find_by(id: pricing.group_id).name,
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
      let(:group_id) { create(:tenants_group, tenant: tenants_tenant, name: 'TEST').id }
      let(:pricing) { create(:pricings_pricing, tenant: tenant, group_id: group_id, itinerary: itinerary) }
      let!(:fee) do
        create(:pricings_fee, pricing_id: pricing.id,
                              range: [
                                { min: 0.0, max: 4.9, rate: 8 },
                                { min: 5.0, max: 10, rate: 12 }
                              ],
                              rate_basis: create(:per_wm_rate_basis),
                              rate: 25,
                              charge_category: create(:bas_charge))
      end
      let(:result) { described_class.write_document(tenant: tenant, user: tenants_user, file_name: 'test.xlsx', sandbox: nil, options: { mode_of_transport: 'ocean', group_id: group_id }) }
      let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
      let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

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
