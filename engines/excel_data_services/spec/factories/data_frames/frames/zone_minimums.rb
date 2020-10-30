# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_zone_minimums_frame, class: "Rover::DataFrame" do
    transient do
      zone_count { 3 }
      minimum { 0 }
      sheet_name { "Rates" }
    end
    initialize_with do
      data = 0.upto(zone_count - 1).map.with_index { |_range, index|
        {
          "zone_minimum" => minimum,
          "zone_minimum_row" => 6 + index,
          "zone_minimum_col" => "B",
          "sheet_name" => sheet_name
        }
      }
      new(data, types: ExcelDataServices::DataFrames::DataProviders::Trucking::ZoneMinimum.column_types)
    end
  end
end
