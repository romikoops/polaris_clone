# frozen_string_literal: true

FactoryBot.define do
  factory :mot_scope do
    ocean_container { true }
    ocean_cargo_item { true }
    air_container { false }
    air_cargo_item { false }
    rail_container { false }
    rail_cargo_item { false }
  end
end

# == Schema Information
#
# Table name: mot_scopes
#
#  id               :bigint(8)        not null, primary key
#  ocean_container  :boolean
#  ocean_cargo_item :boolean
#  air_container    :boolean
#  air_cargo_item   :boolean
#  rail_container   :boolean
#  rail_cargo_item  :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
