# frozen_string_literal: true

class Price < ApplicationRecord
  def rounded_attributes
    {
      value: value&.round(2),
      currency: currency
    }
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
