# frozen_string_literal: true

require 'rails_helper'
require 'roo'

RSpec.describe ExcelDataServices::FileWriters::Hubs do
  let(:tenant) { FactoryBot.create(:tenant) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let!(:hubs) { create(:gothenburg_hub, free_out: false, tenant: tenant, mandatory_charge: create(:mandatory_charge), nexus: create(:gothenburg_nexus)) }
  let!(:hub_headers) do
    %w(status
       type
       name
       locode
       latitude
       longitude
       country
       full_address
       free_out
       import_charges
       export_charges
       pre_carriage
       on_carriage
       alternative_names).map(&:upcase)
  end
  let!(:hub_row) do
    [
      'active',
      'ocean',
      'Gothenburg',
      'SEGOT',
      57.694253,
      11.854048,
      'Sweden',
      '438 80 Landvetter, Sweden',
      'false',
      'false',
      'false',
      'false',
      'false',
      nil
    ]
  end

  describe '.perform' do
    it 'creates the routes' do
      result = described_class.write_document(tenant: tenant, user: tenants_user, file_name: 'test.xlsx', sandbox: nil, options: {})
      xlsx = Roo::Excelx.new(StringIO.new(result.file.download))
      first_sheet = xlsx.sheet(xlsx.sheets.first)
      expect(first_sheet.row(1)).to eq(hub_headers)
      expect(first_sheet.row(2)).to eq(hub_row)
    end
  end
end
