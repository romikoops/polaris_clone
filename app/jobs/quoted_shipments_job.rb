# require 'rails_helper'

class QuotedShipmentsJob < ApplicationJob
  queue_as :critical

  def perform(shipment:, send_email:)
    QuotedShipmentsService.new(shipment: shipment, send_email: send_email).perform
  end
end
