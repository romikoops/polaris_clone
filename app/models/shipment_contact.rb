# frozen_string_literal: true

class ShipmentContact < ApplicationRecord
  CONTACT_TYPES = %w(shipper consignee notifyee).freeze

  belongs_to :shipment
  belongs_to :contact

  CustomValidations.inclusion(self, :contact_type, CONTACT_TYPES)
end
