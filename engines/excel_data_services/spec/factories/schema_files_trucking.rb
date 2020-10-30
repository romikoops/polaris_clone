# frozen_string_literal: true

FactoryBot.define do
  factory :schema_files_trucking, class: "ExcelDataServices::Schemas::Files::Trucking" do
    file { instance_double("xlsx") }
  end
end
