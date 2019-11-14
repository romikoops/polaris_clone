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
