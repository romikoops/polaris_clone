# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe Invoice, type: :model do
    let(:shipment) { FactoryBot.create(:shipments_shipment) }

    it 'guarantees unique sequential gapless invoice numbers' do
      FactoryBot.create(:shipments_invoice, shipment: shipment)
      threads = Array.new(5) do
        Thread.new do
          FactoryBot.create(:shipments_invoice, shipment: shipment)
        end
      end
      threads.each(&:join)

      expect(Invoice.pluck(:invoice_number)).to match_array([1, 2, 3, 4, 5, 6, 7])
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
