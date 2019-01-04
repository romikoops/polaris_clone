FactoryBot.define do
  factory :contact do
    association :user
    association :address
    company_name "Example Company"
    first_name "John"
    last_name "Smith"
    phone "1234567"
    email "email@email.com"
  end
end