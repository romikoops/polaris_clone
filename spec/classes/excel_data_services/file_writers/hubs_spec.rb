# frozen_string_literal: true

require 'rails_helper'
require 'roo'

RSpec.describe ExcelDataServices::FileWriters::Hubs do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let!(:hubs) { create(:gothenburg_hub, free_out: false, organization: organization, mandatory_charge: create(:mandatory_charge), nexus: create(:gothenburg_nexus)) }
  let!(:hub_headers) do
    %w(status
       type
       name
       locode
       terminal
       terminal_code
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
      nil,
      nil,
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
      result = described_class.write_document(organization: organization, user: user, file_name: 'test.xlsx', options: {})
      xlsx = Roo::Excelx.new(StringIO.new(result.file.download))
      first_sheet = xlsx.sheet(xlsx.sheets.first)
      expect(first_sheet.row(1)).to eq(hub_headers)
      expect(first_sheet.row(2)).to eq(hub_row)
    end
  end
end
