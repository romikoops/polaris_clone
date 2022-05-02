# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Tables::CellParser do
  let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_pricings.xlsx").to_s) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:sheet_name) { "Sheet1" }
  let(:header) { "service" }
  let(:column) do
    ExcelDataServices::V4::Files::Tables::Matrix.new(
      xlsx: xlsx,
      header: header,
      rows: "1",
      columns: "A",
      sheet_name: sheet_name,
      options: ExcelDataServices::V4::Files::Tables::Options.new(options: options)
    )
  end
  let(:cell) { described_class.new(container: column, input: input, row: "1", column: "A") }

  before do
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    shared_examples_for "a successful sanitization" do
      it "returns the sanitized value and has no error", :aggregate_failures do
        expect(cell.value).to eq(expected_value)
        expect(cell.error).to be_blank
      end
    end

    context "when the sanitizer is text" do
      let(:options) do
        {
          sanitizer: "text"
        }
      end
      let(:input) { 1 }
      let(:expected_value) { "1" }

      it_behaves_like "a successful sanitization"
    end

    context "when the sanitizer is upcase" do
      let(:options) do
        {
          sanitizer: "upcase"
        }
      end
      let(:input) { "a" }
      let(:expected_value) { "A" }

      it_behaves_like "a successful sanitization"
    end

    context "with nil value and fallback" do
      let(:options) do
        {
          sanitizer: "text",
          fallback: "a"
        }
      end
      let(:input) { nil }
      let(:expected_value) { "a" }

      it_behaves_like "a successful sanitization"
    end

    context "with invalid value" do
      let(:options) do
        {
          sanitizer: "text",
          validator: "locode"
        }
      end
      let(:input) { "aaa" }
      let(:expected_value) { "a" }

      it "returns a DataFrame of sanitized value", :aggregate_failures do
        expect(cell.value).to eq(input)
        expect(cell.error).to be_a(ExcelDataServices::V4::Files::Error)
        expect(cell.error.reason).to eq("The value: aaa of the key: service is not a valid Locode.")
      end
    end
  end
end
