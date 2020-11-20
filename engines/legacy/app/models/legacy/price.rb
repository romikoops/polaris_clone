# frozen_string_literal: true

module Legacy
  class Price < ApplicationRecord
    self.table_name = "prices"
    belongs_to :charge, optional: true, class_name: "Legacy::Charge"

    def rounded_attributes
      {
        value: value&.round(2),
        currency: currency
      }
    end

    def money
      Money.new(value * 100.0, currency)
    end

    def money=(money_obj)
      self.value = money_obj.cents / 100.0
      self.currency = money_obj.currency
      save
    end
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
