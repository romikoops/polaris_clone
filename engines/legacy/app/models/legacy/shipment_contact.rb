# frozen_string_literal: true

module Legacy
  class ShipmentContact < ApplicationRecord
    self.table_name = "shipment_contacts"

    CONTACT_TYPES = %w[shipper consignee notifyee].freeze

    belongs_to :shipment
    belongs_to :contact

    validates :contact_id, uniqueness: {scope: :shipment_id}
  end
end

# == Schema Information
#
# Table name: shipment_contacts
#
#  id           :bigint           not null, primary key
#  contact_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  contact_id   :integer
#  sandbox_id   :uuid
#  shipment_id  :integer
#
# Indexes
#
#  index_shipment_contacts_on_sandbox_id  (sandbox_id)
#
