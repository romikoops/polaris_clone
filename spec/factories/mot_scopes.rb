# frozen_string_literal: true

FactoryBot.define do
  factory :mot_scope do
    ocean_container true
    ocean_cargo_item true
    air_container false
    air_cargo_item false
    rail_container false
    rail_cargo_item false

  end

end
