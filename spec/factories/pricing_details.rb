# frozen_string_literal: true

FactoryBot.define do
  factory :pricing_detail do
    rate 1111
    rate_basis 'PER_CONTAINER'
    shipping_type 'BAS'
    currency_name 'EUR'
  end

end
