# frozen_string_literal: true

FactoryBot.define do
  factory :excel_data_services_files_section, class: "ExcelDataServices::V3::Files::Section" do
    state { FactoryBot.build(:files_state) }

    initialize_with do
      new(state: state)
    end
  end
end
