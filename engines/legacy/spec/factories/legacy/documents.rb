# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_document, class: 'Legacy::Document' do
    association :shipment
    association :tenant

    trait :with_file do
      after(:build) do |document|
        document.file.attach(io: StringIO.new, filename: 'test-image.jpg', content_type: 'image/jpg')
      end
    end
  end
end
