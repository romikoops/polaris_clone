# frozen_string_literal: true

FactoryBot.define do
  factory :file_descriptor, class: "Files::FileDescriptor" do
    file_path { "/download/sailing_schedule/schedule1.xml" }
    file_type { "schedule" }
    originator { "SFTP" }
    status { "ready" }
    source { "itsmycargo_databucket" }
    source_type { "S3_BUCKET" }
    association :organization, factory: :organizations_organization
  end
end
