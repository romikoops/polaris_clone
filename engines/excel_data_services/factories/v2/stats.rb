# frozen_string_literal: true

FactoryBot.define do
  factory :excel_data_services_stats, class: "ExcelDataServices::V2::Stats" do

    type { "pricings" }
    created { 1 }
    failed { 0 }
    errors { [] }

    initialize_with do
      new(type: type, created: created, failed: failed, errors: errors)
    end
  end
end
