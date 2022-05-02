# frozen_string_literal: true

FactoryBot.define do
  factory :excel_data_services_state, class: "ExcelDataServices::V3::State" do
    file do
      FactoryBot.create(:legacy_file).tap do |file_object|
        file_object.file.attach(io: xlsx, filename: "test-sheet.xlsx", content_type: "vnd.ms-excel")
      end
    end
    section { "Pricings" }
    overrides do
      FactoryBot.build(:excel_data_service_overrides)
    end

    transient do
      xlsx { File.open(file_fixture("excel/example_pricings.xlsx")) }
      organization { FactoryBot.create(:organizations_organization) }
      frame { nil }
    end

    initialize_with do
      new(section: section, file: file, overrides: overrides).tap do |new_state|
        new_state.frame = frame if frame.present?
      end
    end
  end
end
