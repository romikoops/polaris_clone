# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::TypeValidity::PricingOneFeeColAndRanges do
  describe ".type_errors" do
    let(:valid_data_sheet) do
      { sheet_name: "Europe",
        restructurer_name: "saco_shipping",
        rows_data: [{ effective_date: Date.parse("Tue, 23 Jul 2019"),
                      expiration_date: Date.parse("Tue, 23 Jul 2019"),
                      hub: "Jebel Ali",
                      country: "United Arab Emirates",
                      fee: "Export Documentation Fee",
                      counterpart_hub: nil,
                      counterpart_country: nil,
                      service_level: nil,
                      carrier: "Hamburg Sud",
                      fee_code: "DOC",
                      direction: "export",
                      rate_basis: "PER_CONTAINER",
                      mot: "ocean",
                      load_type: "fcl_20",
                      currency: "EUR",
                      row_nr: 2 }] }
    end

    it "returns type errors if any for the specified sheet validator" do
      type_validator_class = described_class.get(valid_data_sheet[:restructurer_name])
      type_validator = type_validator_class.new(sheet: valid_data_sheet)
      expect(type_validator.type_errors).to eq([])
    end
  end
end
