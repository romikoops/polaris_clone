# frozen_string_literal: true

class Price < ApplicationRecord
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
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
#  id         :bigint           not null, primary key
#  value      :decimal(, )
#  currency   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
