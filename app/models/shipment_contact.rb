# frozen_string_literal: true

class ShipmentContact < ApplicationRecord
  CONTACT_TYPES = %w(shipper consignee notifyee).freeze

  belongs_to :shipment
  belongs_to :contact

  CustomValidations.inclusion(self, :contact_type, CONTACT_TYPES)
end

# == Schema Information
#
# Table name: shipment_contacts
#
#  id           :bigint(8)        not null, primary key
#  shipment_id  :integer
#  contact_id   :integer
#  contact_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
