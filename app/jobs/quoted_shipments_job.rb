# require 'rails_helper'

class QuotedShipmentsJob < ApplicationJob
  concurrency 1, drop: false
  queue_as :critical

  def perform(shipment:, send_email:)
    QuotedShipmentsService.new(shipment: shipment, send_email: send_email).perform
  end
end
