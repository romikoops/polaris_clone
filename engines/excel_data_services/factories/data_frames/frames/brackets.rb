# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_brackets_frame, class: "Rover::DataFrame" do
    transient do
      bracket_counts { [10] }
      max_ranges { [3500] }
      start { 0 }
      sheet_name { "Rates" }
    end
    trait :invalid do
      initialize_with do
        new(
          [{
            "bracket" => "a - H",
            "bracket_row" => 4,
            "bracket_col" => 6,
            "sheet_name" => sheet_name
          }]
        )
      end
    end

    initialize_with do
      col_index = 4
      data = bracket_counts.flat_map.with_index { |bracket_count, bracket_index|
        max = max_ranges[bracket_index] || 3500
        start.upto(max).slice_when { |value| value % (max / bracket_count) }
          .map do |range|
          col_index += 1
          {
            "bracket" => [range.first, range.last].join("-"),
            "bracket_row" => 4,
            "bracket_col" => col_index,
            "sheet_name" => sheet_name
          }
        end
      }
      new(data, types: ExcelDataServices::DataFrames::DataProviders::Trucking::Brackets.column_types)
    end
  end
end
