# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe ShipmentRequest, type: :model do
    it 'has many documents as attachables' do
      is_expected.to respond_to(:documents)
    end

    it 'creates a valid shipment request' do
      shipment_request = FactoryBot.create :shipments_shipment_request
      expect(shipment_request.valid?).to eql(true)
    end

    it 'creates a an object with consignee, consignor, and notifyee' do
      shipment_request = FactoryBot.build :shipments_shipment_request

      consignee = FactoryBot.build(:shipments_shipment_request_contact, :as_consignee)
      consignor = FactoryBot.build(:shipments_shipment_request_contact, :as_consignor)
      notifyees = FactoryBot.build_list(:shipments_shipment_request_contact, 2, :as_notifyee)

      shipment_request.consignee = consignee
      shipment_request.consignor = consignor
      shipment_request.notifyees = notifyees

      expect(shipment_request.consignee.type).to eq('Shipments::ShipmentRequestContacts::Consignee')
      expect(shipment_request.consignor.type).to eq('Shipments::ShipmentRequestContacts::Consignor')
      expect(shipment_request.notifyees.first.type).to eq('Shipments::ShipmentRequestContacts::Notifyee')
    end
  end
end

# == Schema Information
#
# Table name: shipments_shipment_requests
#
#  id            :uuid             not null, primary key
#  cargo_notes   :string
#  eori          :string
#  eta           :datetime
#  etd           :datetime
#  incoterm_text :string
#  notes         :string
#  ref_number    :string           not null
#  status        :string
#  submitted_at  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sandbox_id    :uuid
#  tenant_id     :uuid             not null
#  tender_id     :uuid             not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_shipments_shipment_requests_on_sandbox_id  (sandbox_id)
#  index_shipments_shipment_requests_on_tenant_id   (tenant_id)
#  index_shipments_shipment_requests_on_tender_id   (tender_id)
#  index_shipments_shipment_requests_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#  fk_rails_...  (tenant_id => tenants_tenants.id)
#  fk_rails_...  (tender_id => quotations_tenders.id)
#  fk_rails_...  (user_id => tenants_users.id)
#
