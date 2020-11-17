# frozen_string_literal: true

FactoryBot.define do
  factory :rovers_base, class: "ExcelDataServices::DataFrames::DataProviders::Base" do
    schema { FactoryBot.create(:schemas_sheets_trucking_fees) }
    transient do
      zone_count { 3 }
    end
    initialize_with do
      new(schema: schema)
    end
  end
end
