# frozen_string_literal: true

FactoryBot.define do
  factory :schemas_file_hubs, class: "ExcelDataServices::Schemas::Files::Hubs" do
    file { "xlsx" }
    initialize_with do
      new(file: file)
    end
  end
end
