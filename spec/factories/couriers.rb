FactoryBot.define do
  factory :courier do
  	name "example courier"
  	association :tenant
  end
end