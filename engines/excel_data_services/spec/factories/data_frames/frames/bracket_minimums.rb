# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_bracket_minimums_frame, class: "Rover::DataFrame" do
    transient do
      bracket_counts { [10] }
      minimum { 25 }
      sheet_name { "Rates" }
    end

    initialize_with do
      col_index = 4
      data = bracket_counts.map { |bracket_count|
        0.upto(bracket_count).map do |index|
          col_index += index
          {
            "bracket_minimum" => minimum,
            "bracket_minimum_row" => 5,
            "bracket_minimum_col" => col_index,
            "sheet_name" => sheet_name
          }
        end
      }
      new(data.flatten, types: ExcelDataServices::DataFrames::DataProviders::Trucking::BracketMinimum.column_types)
    end
  end
end
