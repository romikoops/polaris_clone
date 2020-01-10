# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_rate_basis, class: 'Legacy::RateBasis' do
    external_code { 'PER_HBL' }
    internal_code { 'PER_SHIPMENT' }
  end
end
