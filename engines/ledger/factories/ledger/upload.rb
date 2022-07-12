# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_upload, class: "Ledger::Upload" do
    association :organization, factory: :organizations_organization
    association :file, factory: :legacy_file
    association :user, factory: :users_user

    last_job_id { "63546232-fc34-438e-afd1-fe5c33896931" }
    status { "not_started" }

    trait :with_processing_errors do
      processing_errors { { "errors" => [{ "sheet" => "A", "row" => "10", "reason" => "some error" }] } }
    end
  end
end
