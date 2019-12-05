# frozen_string_literal: true

module Shipments
  class ShipmentRequestContact < ApplicationRecord
    belongs_to :shipment_request
    belongs_to :contact, class_name: 'AddressBook::Contact'
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
