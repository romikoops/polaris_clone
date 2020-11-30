# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::FileParser do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) do
    {organization: organization,
     xlsx: xlsx,
     headers_for_all_sheets: headers_for_all_sheets,
     restructurer_names_for_all_sheets: restructurer_names_for_all_sheets}
  end

  describe ".parse" do
    let(:xlsx) { Roo::Spreadsheet.open(file_fixture("dummy.xlsx").to_s) }
    let(:headers_for_all_sheets) { {"Sheet1" => %i[fee_code some_test_date], "Sheet2" => [:abc]} }
    let(:restructurer_names_for_all_sheets) {
      {"Sheet1" => "some_restructurer_name", "Sheet2" => "other_restructurer_name"}
    }
    let(:correctly_parsed_data) do
      [
        {sheet_name: "Sheet1", restructurer_name: "some_restructurer_name", rows_data: [
          {fee_code: "BAS", some_test_date: Date.parse("Tue, 01 Jan 2019"), row_nr: 2}
        ]},
        {sheet_name: "Sheet2", restructurer_name: "other_restructurer_name", rows_data: [
          {abc: "Test", row_nr: 2}
        ]}
      ]
    end

    it "returns successfully" do
      expect(described_class.parse(options)).to eq(correctly_parsed_data)
    end
  end
end
