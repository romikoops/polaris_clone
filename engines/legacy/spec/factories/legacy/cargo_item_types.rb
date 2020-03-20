# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_cargo_item_type, class: 'Legacy::CargoItemType' do
    dimension_x { 101 }
    dimension_y { 121 }
    description { 'Pallet' }
    area { '' }
    category { 'Pallet' }
  end
end

# == Schema Information
#
# Table name: cargo_item_types
#
#  id          :bigint           not null, primary key
#  area        :string
#  category    :string
#  description :string
#  dimension_x :decimal(, )
#  dimension_y :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
