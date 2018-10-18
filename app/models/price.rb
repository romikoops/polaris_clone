# frozen_string_literal: true

class Price < ApplicationRecord
  def rounded_attributes
    {
      value: value&.round(2),
      currency: currency
    }
  end
end
