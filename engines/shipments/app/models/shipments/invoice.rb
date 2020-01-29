# frozen_string_literal: true

module Shipments
  class Invoice < ApplicationRecord
    has_paper_trail unless: proc { |t| t.sandbox_id.present? }

    attr_readonly :invoice_number

    belongs_to :shipment
    has_many :line_items

    around_create :generate_invoice_number

    def generate_invoice_number
      transaction do
        self.invoice_number = Sequential::Sequence.next(:shipment_invoice_number)
        yield
      end
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
