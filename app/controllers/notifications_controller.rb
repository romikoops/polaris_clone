# frozen_string_literal: true

class NotificationsController < ApplicationController
  skip_before_action :require_non_guest_authentication!
  include NotificationTools
  include Response
  def index
    if current_user && current_user.role.name == 'shipper'
      messages = get_messages_for_user(current_user)
      response_handler(messages)
    elsif current_user && current_user.role.name == 'admin'
      messages = get_messages_for_admin(current_user)
      response_handler(messages)
    elsif current_user && current_user.role.name == 'sub_admin'
      messages = get_messages_for_manager(current_user)
      response_handler(messages)
    else
      response_handler(conversations: {})
    end
  end

  def send_message
    message = params[:message].as_json
    isAdmin = current_user.role.name.include?('admin')
    user = isAdmin ? Shipment.find_by_imc_reference(message['shipmentRef']).user : current_user
    resp = add_message_to_convo(user, message, isAdmin)
    response_handler(resp)
  end

  def mark_as_read
    shipment = Shipment.find_by_imc_reference(params[:shipmentRef])
    shipment.messages.each do |message|
      message.read = true
      message.save!
    end

    response_handler(messages)
  end

  def shipment_data
    @shipment = Shipment.find_by_imc_reference(params[:ref])
    @cargo_items = @shipment.cargo_items
    @containers = @shipment.containers
    @shipment_contacts = @shipment.shipment_contacts
    @contacts = []
    @shipment_contacts.each do |sc|
      @contacts.push(contact: sc.contact, type: sc.contact_type, address: sc.contact.address)
    end
    hubs = { startHub: {}, endHub: {} }

    @documents = @shipment.documents.select { |doc| doc.file.attached? }.map do |doc|
      doc.as_json.merge(signed_url: rails_blob_url(doc.file, disposition: 'attachment'))
    end
    resp = { shipment: @shipment.with_address_options_json, cargoItems: @cargo_items, containers: @containers, contacts: @contacts, documents: @documents, schedules: @schedules, hubs: hubs }
    response_handler(resp)
  end

  def shipments_data
    results = {
    }
    shipment_keys = params[:keys] || current_user.shipments.pluck(:imc_reference)
    shipment_keys.each do |k|
      shipment = Shipment.find_by_imc_reference(k)
      results[k] = shipment
    end
    response_handler(results)
  end
end
