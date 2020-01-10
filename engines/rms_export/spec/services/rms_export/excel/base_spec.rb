# frozen_string_literal: true

require 'rails_helper'
require 'roo'

RSpec.describe ::RmsExport::Excel::Base do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:tenants_tenant) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowest', tenant: tenant) }
  let!(:carrier) { FactoryBot.create(:routing_carrier) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let!(:pricing) { FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle) }
  let!(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle) }
  let!(:pricing_headers) do
    %w(EFFECTIVE_DATE	EXPIRATION_DATE	ORIGIN	COUNTRY_ORIGIN
       DESTINATION	COUNTRY_DESTINATION	MOT
       CARRIER	SERVICE_LEVEL	LOAD_TYPE	RATE_BASIS
       RANGE_MIN	RANGE_MAX	FEE_CODE	FEE_NAME
       CURRENCY	FEE_MIN	FEE)
  end
  let!(:pricing_row) do
    [
      pricing.effective_date.to_s,
      pricing.expiration_date.to_s,
      'Gothenburg',
      'Sweden',
      'Shanghai',
      'China',
      'ocean',
      nil,
      'slowest',
      'lcl',
      'PER_WM',
      nil,
      nil,
      'bas',
      'Basic Ocean Freight',
      'EUR',
      '1.0',
      '25.0'
    ]
  end

  describe '.perform' do
    it 'creates the routes' do
      RmsSync::Pricings.new(tenant_id: tenants_tenant.id, sheet_type: :pricings).perform
      result = described_class.write_document(tenant_id: tenants_tenant.id, sheet_type: :pricings)
      xlsx = Roo::Excelx.new(StringIO.new(result.file.download))
      first_sheet = xlsx.sheet(xlsx.sheets.first)
      expect(first_sheet.row(1)).to eq(pricing_headers)
      expect(first_sheet.row(2)).to eq(pricing_row)
    end
  end
end
