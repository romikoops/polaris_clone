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
#  sandbox_id     :uuid
#  shipment_id    :uuid             not null
#  invoice_number :bigint
#  amount_cents   :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
