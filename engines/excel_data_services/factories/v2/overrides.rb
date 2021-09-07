# frozen_string_literal: true

FactoryBot.define do
  factory :excel_data_services_overrides, class: "ExcelDataServices::V2::Overrides" do
    file do
      FactoryBot.create(:legacy_file).tap do |file_object|
        file_object.file.attach(io: xlsx, filename: "test-sheet.xlsx", content_type: "vnd.ms-excel")
      end
    end
    group_id { nil }

    transient do
      xlsx { File.open(file_fixture("excel/example_pricings.xlsx")) }
    end

    initialize_with do
      new(group_id: group_id, document_id: file.id)
    end
  end
end
