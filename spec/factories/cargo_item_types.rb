# frozen_string_literal: true

FactoryBot.define do
  factory :cargo_item_type do
    width { 101 }
    length { 121 }
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
#  area        :string
#  category    :string
#  description :string
#  dimension_x :decimal(, )
#  dimension_y :decimal(, )
#  length      :decimal(, )
#  width       :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
