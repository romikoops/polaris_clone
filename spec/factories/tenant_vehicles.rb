# frozen_string_literal: true

FactoryBot.define do
  factory :tenant_vehicle do
    name 'standard'
    mode_of_transport 'ocean'
    association :tenant
    association :vehicle
  end

end
