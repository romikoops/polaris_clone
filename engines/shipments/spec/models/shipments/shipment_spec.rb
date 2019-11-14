# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe Shipment, type: :model do
    describe 'validity' do
      let(:shipment) { FactoryBot.build(:shipments_shipment) }

      it 'creates a valid object' do
        expect(shipment).to be_valid
      end

      it 'has many documents as attachables' do
        is_expected.to respond_to(:documents)
      end
    end
  end
end
