# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_values_frame, class: "Rover::DataFrame" do
    transient do
      bracket_counts { [10] }
      zone_count { 3 }
      minimum { 25 }
      start_value { 2 }
      value { nil }
      sheet_name { "Rates" }
    end

    initialize_with do
      new(
        0.upto(zone_count).flat_map { |zone|
          col_index = 4
          bracket_counts.flat_map do |bracket_count|
            0.upto(bracket_count).map do |count|
              col_index += count
              {
                "value" => value || start_value * (1 - (count / 100.0)),
                "value_row" => 6 + zone,
                "value_col" => col_index,
                "sheet_name" => sheet_name
              }
            end
          end
        },
        types: ExcelDataServices::DataFrames::DataProviders::Trucking::Values.column_types
      )
    end
  end
end
