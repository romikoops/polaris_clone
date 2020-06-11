# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Rows::Hubs do
  let(:tenant) { create(:tenant) }
  let(:input_data) do
    {status: "active",
     type: "ocean",
     name: "Abu Dhabi",
     locode: "AEAUH",
     latitude: 24.806936,
     longitude: 54.644405,
     country: "United Arab Emirates",
     full_address: "Khalifa Port - Abu Dhabi - United Arab Emirates",
     photo: nil,
     free_out: false,
     import_charges: true,
     export_charges: false,
     pre_carriage: false,
     on_carriage: false,
     alternative_names: nil,
     row_nr: 2}
  end
  let(:row) { described_class.new(tenant: tenant, row_data: input_data) }

  describe ".locode" do
    it "returns the lcoode from the row" do
      expect(row.locode).to eq("AEAUH")
    end
  end
end
