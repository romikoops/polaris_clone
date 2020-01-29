# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_price, class: 'Legacy::Price' do
    value { '9.99' }
    currency { 'EUR' }
  end
end

# == Schema Information
#
# Table name: prices
#
#  id         :bigint           not null, primary key
#  currency   :string
#  value      :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
# Indexes
#
#  index_prices_on_sandbox_id  (sandbox_id)
#
