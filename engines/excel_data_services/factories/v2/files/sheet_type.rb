# frozen_string_literal: true

FactoryBot.define do
  factory :excel_data_services_files_sheet_type, class: "ExcelDataServices::V2::Files::SheetType" do
    file do
      FactoryBot.create(:legacy_file).tap do |file_object|
        file_object.file.attach(io: xlsx, filename: "test-sheet.xlsx", content_type: "vnd.ms-excel")
      end
    end
    type { "Pricings" }
    arguments do
      {
        hub_id: nil,
        group_id: nil,
        organization_id: organization.id
      }
    end

    transient do
      xlsx { "xlsx" }
      organization { FactoryBot.create(:organizations_organization) }
    end

    initialize_with do
      new(type: type, file: file, arguments: arguments)
    end
  end
end
