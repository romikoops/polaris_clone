# frozen_string_literal: true

FactoryBot.define do
  factory :api_file_wrapper, class: "Api::V1::UploadsController::FileWrapper" do
    content_type { "application/json" }
    filename { "#{SecureRandom.uuid}.json" }
    file_or_string { "{}" }
  end
end
