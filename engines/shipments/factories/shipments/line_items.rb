# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_line_item, class: "Shipments::LineItem" do
    association :invoice, factory: :shipments_invoice

    amount_cents { 1000 }
    fee_code { "HAF" }
  end
end

# == Schema Information
#
# Table name: shipments_line_items
#
#  id              :uuid             not null, primary key
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           not null
#  fee_code        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cargo_id        :uuid
#  invoice_id      :uuid             not null
#
# Indexes
#
#  index_shipments_line_items_on_cargo_id    (cargo_id)
#  index_shipments_line_items_on_invoice_id  (invoice_id)
#
