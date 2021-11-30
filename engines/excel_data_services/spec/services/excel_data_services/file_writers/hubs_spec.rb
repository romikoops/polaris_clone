# frozen_string_literal: true

require "rails_helper"
require "roo"

RSpec.describe ExcelDataServices::FileWriters::Hubs do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:hub_headers) do
    %w[status
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
      alternative_names].map(&:upcase)
  end
  let(:hub_row) do
    [
      "active",
      "ocean",
      "Gothenburg",
      "SEGOT",
      "SEGOT1",
      nil,
      57.694253,
      11.854048,
      "Sweden",
      "438 80 Landvetter, Sweden",
      "false",
      "false",
      "false",
      "false",
      "false",
      nil
    ]
  end

  before do
    FactoryBot.create(:gothenburg_hub,
      free_out: false,
      organization: organization,
      terminal: "SEGOT1",
      mandatory_charge: FactoryBot.create(:legacy_mandatory_charge),
      nexus: FactoryBot.create(:gothenburg_nexus))
  end

  describe "#perform" do
    let(:result) { described_class.write_document(organization: organization, user: user, file_name: "test.xlsx", options: {}) }
    let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
    let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

    it "renders the hub correctly in the row", :aggregate_failures do
      expect(first_sheet.row(1)).to eq(hub_headers)
      expect(first_sheet.row(2)).to eq(hub_row)
    end
  end
end
