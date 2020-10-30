# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_zone_rows_frame, class: "Rover::DataFrame" do
    transient do
      zone_count { 3 }
      sheet_name { "Rates" }
    end
    initialize_with do
      data = 0.upto(zone_count - 1).map { |count|
        {
          "zone" => (count + 1).to_f,
          "zone_row" => 6 + count,
          "zone_col" => "A",
          "sheet_name" => sheet_name
        }
      }
      new(data, types: ExcelDataServices::DataFrames::DataProviders::Trucking::ZoneRow.column_types)
    end
  end
end
