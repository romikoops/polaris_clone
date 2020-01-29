# frozen_string_literal: true

module Quotations
  class LineItem < ApplicationRecord
    belongs_to :tender, required: true, inverse_of: :line_items
    belongs_to :charge_category, class_name: 'Legacy::ChargeCategory'

    monetize :amount_cents
  end
end

# == Schema Information
#
# Table name: quotations_line_items
#
#  id                 :uuid             not null, primary key
#  amount_cents       :integer
#  amount_currency    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  charge_category_id :bigint
#  tender_id          :uuid
#
# Indexes
#
#  index_quotations_line_items_on_charge_category_id  (charge_category_id)
#  index_quotations_line_items_on_tender_id           (tender_id)
#
