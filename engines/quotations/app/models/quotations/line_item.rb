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
#  tender_id          :uuid
#  charge_category_id :bigint
#  amount_cents       :integer
#  amount_currency    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
