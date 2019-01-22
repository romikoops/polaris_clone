# frozen_string_literal: true

FactoryBot.define do
  factory :pricing_exception do
    effective_date { DateTime.now }
    expiration_date { 1.week.from_now }
    association :pricing
    association :tenant
  end
end
