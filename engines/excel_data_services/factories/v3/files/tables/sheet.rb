# frozen_string_literal: true

FactoryBot.define do
  factory :excel_data_services_files_tables_sheet, class: "ExcelDataServices::V3::Files::Tables::Sheet" do
    section { FactoryBot.build(:files_section) }
    sheet_name { "Sheet1" }
    initialize_with do
      new(section: section, sheet_name: sheet_name)
    end
  end
end
