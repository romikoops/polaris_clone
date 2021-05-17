# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Rows::Pricing do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:input_data) do
    { sheet_name: "Sheet1",
      restructurer_name: "pricing_one_fee_col_and_ranges",
      effective_date: Date.parse("Thu, 15 Mar 2018"),
      expiration_date: Date.parse("Sun, 15 Nov 2019"),
      origin: "Gothenburg",
      country_origin: "Sweden",
      destination: "Shanghai",
      country_destination: "China",
      mot: "ocean",
      carrier: nil,
      service_level: "standard",
      load_type: "lcl",
      rate_basis: "PER_WM",
      fee_code: "BAS",
      fee_name: "Bas",
      currency: "USD",
      fee_min: 17,
      fee: 17,
      transit_time: 24,
      transshipment: nil,
      row_nr: 2,
      vm_ratio: 800,
      internal: false,
      origin_name: "Gothenburg",
      destination_name: "Shanghai" }
  end
  let(:row) { described_class.new(organization: organization, row_data: input_data) }

  describe ".vm_ratio" do
    it "returns the vm_ratio from the row" do
      expect(row.vm_ratio).to eq(0.8)
    end
  end
end
