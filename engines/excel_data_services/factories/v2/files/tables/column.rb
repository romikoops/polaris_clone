# frozen_string_literal: true

FactoryBot.define do
  factory :excel_data_services_files_tables_column, class: "ExcelDataServices::V2::Files::Tables::Column" do
    transient do
      sanitizer { "downcase" }
      validator { "string" }
      required { false }
      alternative_keys { ["code"] }
      type { :object }
    end

    xlsx { Roo::Spreadsheet.open(file_fixture("excel/example_pricings.xlsx").to_s) }
    header { "fee_code" }
    sheet_name { "Sheet1" }
    options do
      {
        sanitizer: sanitizer,
        validator: validator,
        required: required,
        alternative_keys: alternative_keys,
        type: type
      }
    end

    initialize_with do
      new(
        xlsx: xlsx,
        sheet_name: sheet_name,
        header: header,
        options: options
      )
    end
  end
end
