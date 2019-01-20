# frozen_string_literal: true

FactoryBot.define do
  factory :price do
    value { '9.99' }
    currency { 'EUR' }
  end
end

# == Schema Information
#
# Table name: prices
#
#  id         :bigint(8)        not null, primary key
#  value      :decimal(, )
#  currency   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
