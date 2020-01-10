# frozen_string_literal: true

FactoryBot.define do
  factory :documents, class: 'Document' do
    association :shipment
    association :tenant

    trait :with_file do
      after(:build) do |document|
        document.file.attach(io: StringIO.new, filename: 'test-image.jpg', content_type: 'image/jpg')
      end
    end
  end
end
