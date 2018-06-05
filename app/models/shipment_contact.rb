# frozen_string_literal: true

class ShipmentContact < ApplicationRecord
  belongs_to :shipment
  belongs_to :contact
end
