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
#  type                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  contact_id          :uuid             not null
#  shipment_request_id :uuid             not null
#
# Indexes
#
#  index_shipment_request_contacts_on_contact_id           (contact_id)
#  index_shipment_request_contacts_on_shipment_request_id  (shipment_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => address_book_contacts.id)
#
