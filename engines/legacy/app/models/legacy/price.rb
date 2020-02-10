# frozen_string_literal: true

module Legacy
  class Price < ApplicationRecord
    self.table_name = 'prices'
    belongs_to :charge, optional: true, class_name: 'Legacy::Charge'

    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    def rounded_attributes
      {
        value: value&.round(2),
        currency: currency
      }
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
