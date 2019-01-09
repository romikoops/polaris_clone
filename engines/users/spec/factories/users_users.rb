# frozen_string_literal: true

FactoryBot.define do
  factory :users_user, class: 'Users::User' do
    email { |n| "demo#{n}@itsmycargo.test" }
    name { 'John Doe' }
    google_id { '12341234' }
  end
end
