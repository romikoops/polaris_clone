# frozen_string_literal: true

FactoryBot.define do
  factory :schemas_file_trucking, class: "ExcelDataServices::Schemas::Files::Trucking" do
    file { instance_double("xlsx") }
    initialize_with do
      new(file: file)
    end
  end
end
