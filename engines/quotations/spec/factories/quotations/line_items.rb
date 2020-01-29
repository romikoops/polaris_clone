# frozen_string_literal: true

FactoryBot.define do
  factory :quotations_line_item, class: 'Quotations::LineItem' do
    amount_cents { 30 }
    amount_currency { 'USD' }
    association :tender, factory: :quotations_tender
    association :charge_category, factory: :legacy_charge_categories
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
