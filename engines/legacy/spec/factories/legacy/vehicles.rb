# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_vehicle, class: 'Legacy::Vehicle' do
    name { 'standard' }
    mode_of_transport { 'ocean' }
  end
end
