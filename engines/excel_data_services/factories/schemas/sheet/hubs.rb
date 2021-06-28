# frozen_string_literal: true

FactoryBot.define do
  factory :schemas_sheets_hubs, class: "ExcelDataServices::Schemas::Sheet::Hubs" do
    file { "xlsx_sheet" }
    sheet_name { "Hubs" }
    initialize_with do
      new(file: file, sheet_name: sheet_name)
    end
  end
end
