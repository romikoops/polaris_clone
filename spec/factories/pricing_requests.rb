FactoryBot.define do
  factory :pricing_request do
    association :pricing
    association :tenant
    status "requested"
  end
end
