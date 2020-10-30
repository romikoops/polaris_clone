# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_modifiers_frame, class: "Rover::DataFrame" do
    transient do
      bracket_counts { [10] }
      modifiers { ["kg"] }
      sheet_name { "Rates" }
    end
    initialize_with do
      col_index = 4
      data = bracket_counts.flat_map.with_index { |bracket_count, bracket_index|
        0.upto(bracket_count).map do |count|
          col_index += count
          {
            "modifier" => modifiers[bracket_index] || "kg",
            "modifier_row" => 3,
            "modifier_col" => col_index,
            "sheet_name" => sheet_name
          }
        end
      }
      new(data, types: ExcelDataServices::DataFrames::DataProviders::Trucking::Modifiers.column_types)
    end
  end
end
