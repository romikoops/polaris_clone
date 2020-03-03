# frozen_string_literal: true

FactoryBot.define do
  factory :exchange_rate do
    from { 'USD' }
    to { 'EUR' }
    rate { 1.26 }
  end
end

# == Schema Information
#
# Table name: exchange_rates
#
#  id         :bigint           not null, primary key
#  from       :string
#  rate       :decimal(, )
#  to         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_exchange_rates_on_from  (from)
#  index_exchange_rates_on_to    (to)
#
