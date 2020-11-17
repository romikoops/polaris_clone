# frozen_string_literal: true

FactoryBot.define do
  factory :schemas_sheets_trucking_rates, class: "ExcelDataServices::Schemas::Sheet::TruckingRates" do
    file { "xlsx_sheet" }
    sheet_name { "Rates" }
    initialize_with do
      new(file: file, sheet_name: sheet_name)
    end
  end
end
