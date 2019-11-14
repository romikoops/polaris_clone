# frozen_string_literal: true

module Shipments
  module ShipmentRequestContacts
    class Notifyee < ShipmentRequestContact
    end
  end
end

# == Schema Information
#
# Table name: shipments_shipment_request_contacts
#
#  id                  :uuid             not null, primary key
#  shipment_request_id :uuid             not null
#  contact_id          :uuid             not null
#  type                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
