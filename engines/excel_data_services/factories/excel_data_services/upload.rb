# frozen_string_literal: true

FactoryBot.define do
  factory :excel_data_services_upload, class: "ExcelDataServices::Upload" do
    association :organization, factory: :organizations_organization
    association :file, factory: :legacy_file
    association :user, factory: :users_user

    last_job_id { "63546232-fc34-438e-afd1-fe5c33896931" }
    status { "not_started" }
  end
end
