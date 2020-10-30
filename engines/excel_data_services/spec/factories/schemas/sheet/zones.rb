# frozen_string_literal: true

FactoryBot.define do
  factory :schemas_sheets_trucking_zones, class: "ExcelDataServices::Schemas::Sheet::TruckingZones" do
    file { instance_double("xlsx_sheet") }
    sheet_name { "Zones" }
    initialize_with do
      new(file: file, sheet_name: sheet_name)
    end
  end
end
