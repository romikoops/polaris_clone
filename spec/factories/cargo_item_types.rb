# frozen_string_literal: true

FactoryBot.define do
  factory :cargo_item_type do
    dimension_x { 101 }
    dimension_y { 121 }
    description { '' }
    area { '' }
    category { 'Pallet' }
  end
end

# == Schema Information
#
# Table name: cargo_item_types
#
#  id          :bigint           not null, primary key
#  dimension_x :decimal(, )
#  dimension_y :decimal(, )
#  description :string
#  area        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category    :string
#
