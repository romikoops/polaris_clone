# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::MissingValues::MaxDimensions do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { {organization: organization, sheet_name: "Sheet1", data: input_data} }

  context "with faulty data" do
    let(:input_data) do
      [
        {
          sheet_name: "Sheet1",
          restructurer_name: "max_dimensions",
          carrier: "msc",
          service_level: "standard",
          mode_of_transport: "ocean",
          width: nil,
          length: nil,
          height: nil,
          payload_in_kg: 10_000,
          chargeable_weight: nil,
          cargo_class: "fcl_20",
          aggregate: false,
          origin_locode: nil,
          destination_locode: nil,
          row_nr: 2
        },
        {
          sheet_name: "Sheet1",
          restructurer_name: "max_dimensions",
          carrier: "msc",
          service_level: "standard",
          mode_of_transport: "ocean",
          width: nil,
          length: nil,
          height: nil,
          payload_in_kg: nil,
          chargeable_weight: nil,
          cargo_class: nil,
          aggregate: nil,
          origin_locode: nil,
          destination_locode: "SEGOT",
          row_nr: 3
        }
      ].map { |row| ExcelDataServices::Rows::MaxDimensions.new(organization: organization, row_data: row) }
    end
    let(:validator) { described_class.new(options) }

    describe ".validate" do
      before do
        validator.perform
      end

      let(:expected_errors) do
        [
          {exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
           reason: "Missing value for PAYLOAD_IN_KG.",
           row_nr: 3,
           sheet_name: "Sheet1",
           type: :error},
          {exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
           reason: "Missing value for HEIGHT.",
           row_nr: 3,
           sheet_name: "Sheet1",
           type: :error},
          {exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
           reason: "Missing value for LENGTH.",
           row_nr: 3,
           sheet_name: "Sheet1",
           type: :error},
          {exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
           reason: "Missing value for WIDTH.",
           row_nr: 3,
           sheet_name: "Sheet1",
           type: :error},
          {exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
           reason: "Missing value for CHARGEABLE_WEIGHT.",
           row_nr: 3,
           sheet_name: "Sheet1",
           type: :error},
          {exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
           reason: "Missing value for LOAD_TYPE.",
           row_nr: 3,
           sheet_name: "Sheet1",
           type: :error},
          {exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
           reason: "Both LOCODES must be present",
           row_nr: 3,
           sheet_name: "Sheet1",
           type: :error}
        ]
      end

      it "logs the errors" do
        expect(validator.results).to match_array(expected_errors)
      end
    end
  end
end
