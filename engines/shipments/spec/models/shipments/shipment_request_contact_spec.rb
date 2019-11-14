# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe ShipmentRequestContact, type: :model do
    it 'behaves as sti' do
      expect(described_class).to have_attribute :type
    end

    it 'creates a valid consignee' do
      consignee = FactoryBot.build(:shipments_shipment_request_contact, :as_consignee)
      expect(consignee.valid?).to eq(true)
      expect(consignee).to be_a_kind_of Shipments::ShipmentRequestContact
    end

    it 'creates a valid consignor' do
      consignor = FactoryBot.build(:shipments_shipment_request_contact, :as_consignor)
      expect(consignor.valid?).to eq(true)
      expect(consignor).to be_a_kind_of Shipments::ShipmentRequestContact
    end

    it 'creates a valid notifyee' do
      notifyee = FactoryBot.build(:shipments_shipment_request_contact, :as_notifyee)
      expect(notifyee.valid?).to eq(true)
      expect(notifyee).to be_a_kind_of Shipments::ShipmentRequestContact
    end
  end
end

# == Schema Information
#
# Table name: shipments_shipment_request_contacts
#
#  id                  :uuid             not null, primary key
#  shipment_request_id :integer
#  contact_id          :integer
#  type                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
