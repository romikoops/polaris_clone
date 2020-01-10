# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_role, class: 'Legacy::Role' do
    name { 'shipper' }
  end
end
