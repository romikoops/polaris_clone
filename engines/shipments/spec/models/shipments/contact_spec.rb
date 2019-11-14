# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe Contact, type: :model do
    describe 'validity' do
      let(:shipment) { FactoryBot.build(:shipments_shipment) }
      let(:consignor) { FactoryBot.build(:shipments_contact, :consignor, shipment: shipment) }
      let(:consignee) { FactoryBot.build(:shipments_contact, :consignee, shipment: shipment) }

      it 'is valid' do
        expect(consignee).to be_valid
        expect(consignor).to be_valid
      end
    end
  end
end
