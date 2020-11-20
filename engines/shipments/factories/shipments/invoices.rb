# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_invoice, class: "Shipments::Invoice" do
    amount_cents { 1000 }

    after(:build) do
      Sequential::Sequence.where(name: :shipment_invoice_number, value: 0).first_or_create
    end
  end
end

# == Schema Information
#
# Table name: shipments_invoices
#
#  id             :uuid             not null, primary key
#  amount_cents   :integer          default(0), not null
#  invoice_number :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  sandbox_id     :uuid
#  shipment_id    :uuid             not null
#
# Indexes
#
#  index_shipments_invoices_on_sandbox_id   (sandbox_id)
#  index_shipments_invoices_on_shipment_id  (shipment_id)
#
# Foreign Keys
#
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#
