# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_country_codes_frame, class: "Rover::DataFrame" do
    transient do
      zone_count { 3 }
      sheet_name { "Rates" }
      query_method { "zipcode" }
      country_code { "DE" }
    end
    initialize_with do
      data = 0.upto(zone_count - 1).map { |count|
        {
          "country_code" => country_code,
          "zone_row" => 6 + count,
          "zone_col" => "A",
          "query_method" => query_method,
          "sheet_name" => sheet_name
        }
      }
      new(data, types: ExcelDataServices::DataFrames::DataProviders::Trucking::CountryCodes.column_types)
    end
  end
end
