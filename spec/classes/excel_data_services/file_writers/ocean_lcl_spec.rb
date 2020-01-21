# frozen_string_literal: true

require 'rails_helper'
require 'roo'

RSpec.describe ExcelDataServices::FileWriters::OceanLcl do
  let(:tenant) { FactoryBot.create(:tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:itinerary) { create(:gothenburg_shanghai_itinerary) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let!(:pricing_headers) do
    (ExcelDataServices::Validators::HeaderChecker::VARIABLE | ExcelDataServices::FileWriters::Base::HEADER_COLLECTION::PRICING_ONE_COL_FEE_AND_RANGES).map(&:upcase).map(&:to_s)
  end
  let(:legacy_pricing_row) do
    [
      pricing.respond_to?(:group_id) ? pricing.group_id : nil,
      pricing.respond_to?(:group_id) ? Tenants::Group.find_by(id: pricing.group_id)&.name : nil,
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
      nil,
      nil,
      'BAS',
      'BAS',
      'EUR',
      pricing.respond_to?(:group_id) ? 1 : nil,
      25
    ]
  end
  let(:base_pricing_row) do
    [
      pricing.group_id,
      Tenants::Group.find_by(id: pricing.group_id)&.name,
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
      nil,
      nil,
      'BAS',
      'Basic Ocean Freight',
      'EUR',
      1,
      25
    ]
  end


  context 'when all pricings are valid' do
    let!(:pricing) { create(:legacy_lcl_pricing, tenant: tenant, itinerary: itinerary) }
    let(:result) { described_class.write_document(tenant: tenant, user: tenants_user, file_name: 'test.xlsx') }
    let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
    let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }
    describe '.perform' do
      it 'writes all pricings to the sheet' do
        aggregate_failures 'testing sheet values' do
          expect(first_sheet.row(1)).to eq(pricing_headers)
          expect(first_sheet.row(2)).to eq(legacy_pricing_row)
        end
      end
    end
  end

  context 'when all pricings are valid with attached group' do
    before do
      create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true })
    end

    let(:group) { create(:tenants_group, tenant: tenants_tenant, name: 'TEST') }
    let!(:pricing) { create(:lcl_pricing, tenant: tenant, group_id: group.id, itinerary: itinerary) }
    let(:result) { described_class.write_document(tenant: tenant, user: tenants_user, file_name: 'test.xlsx') }
    let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
    let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

    describe '.perform' do
      it 'writes all pricings to the sheet' do
        aggregate_failures 'testing sheet values' do
          expect(first_sheet.row(1)).to eq(pricing_headers)
          expect(first_sheet.row(2)).to eq(base_pricing_row)
        end
      end
    end
  end
end
