# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::TypeValidity::MaxDimensions do
  describe ".type_errors" do
    let(:valid_data_sheet) do
      { sheet_name: "MaxDimensions",
        restructurer_name: "max_dimensions",
        rows_data: [{ carrier: "msc",
                      service_level: "faster",
                      mode_of_transport: "ocean",
                      width: 0.1e4,
                      length: 0.9e3,
                      height: 0.12e4,
                      payload_in_kg: 0.1e5,
                      chargeable_weight: 0.1e5,
                      load_type: "lcl",
                      aggregate: true,
                      origin_locode: 0,
                      destination_locode: "USNYC",
                      row_nr: 3 }] }
    end

    it "returns type errors if any for the specified sheet validator" do
      type_validator_class = described_class.get(valid_data_sheet[:restructurer_name])
      type_validator = type_validator_class.new(sheet: valid_data_sheet)
      expect(type_validator.type_errors).to eq([{
        exception_class: ExcelDataServices::Validators::ValidationErrors::TypeValidity::OptionalLocodeType,
        reason: "The value: 0 of the key: origin_locode is not a valid optional locode type.",
        row_nr: 3,
        sheet_name: "MaxDimensions",
        type: :error
      }])
    end
  end
end
