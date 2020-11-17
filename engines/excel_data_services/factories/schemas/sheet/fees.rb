# frozen_string_literal: true

FactoryBot.define do
  factory :schemas_sheets_trucking_fees, class: "ExcelDataServices::Schemas::Sheet::TruckingFees" do
    file { "xlsx_sheet" }
    sheet_name { "Fees" }
    initialize_with do
      new(file: file, sheet_name: sheet_name)
    end
  end
end
