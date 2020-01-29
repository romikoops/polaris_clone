# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_currency, class: 'Legacy::Currency' do
    base { 'EUR' }
    today { { 'EUR' => 1, 'USD' => 1.120454 } }
    updated_at { Date.current }
  end
end

# == Schema Information
#
# Table name: currencies
#
#  id         :bigint           not null, primary key
#  base       :string
#  today      :jsonb
#  yesterday  :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :integer
#
# Indexes
#
#  index_currencies_on_tenant_id  (tenant_id)
#
