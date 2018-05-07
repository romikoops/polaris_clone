class NotificationsController < ApplicationController
  skip_before_action :require_non_guest_authentication!
  include NotificationTools
  include Response
  def index
    if current_user && current_user.role.name == "shipper"
      messages = get_messages_for_user(current_user)
      response_handler(messages)
    elsif current_user && current_user.role.name == "admin"
      messages = get_messages_for_admin(current_user)
      response_handler(messages)
    elsif current_user && current_user.role.name == "sub_admin"
      messages = get_messages_for_manager(current_user)
      response_handler(messages)
    else
      response_handler({conversations: {}})
    end
  end

  def send_message
    message = params[:message].as_json
    isAdmin = current_user.role.name.include?("admin")
    user = isAdmin ? Shipment.find_by_imc_reference(message["shipmentRef"]).user : current_user
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
      @contacts.push({contact: sc.contact, type: sc.contact_type, location: sc.contact.location})
    end
    hubs = {startHub: {}, endHub:{}}
    @schedules = @shipment.schedule_set
    hubs[:startHub] = Hub.find(@schedules.first["hub_route_key"].split("-")[0].to_i)
    hubs[:endHub] = Hub.find(@schedules.last["hub_route_key"].split("-")[1].to_i)
    @documents = []
    @shipment.documents.each do |doc|
      tmp = doc.as_json
      tmp["signed_url"] =  doc.get_signed_url
      @documents << tmp
    end
    resp = {shipment: @shipment, cargoItems: @cargo_items, containers: @containers, contacts: @contacts, documents: @documents, schedules: @schedules, hubs: hubs}
    response_handler(resp)
  end
  def shipments_data
    results = {
      requested: [],
      open: [],
      finished: [],
      ignored: []
    }
    params[:keys].each do |k|
      shipment = Shipment.find_by_imc_reference(k)
      case shipment.status
      when "requested"
        results[:requested] << shipment
      when "accepted" || "in_progress"
        results[:open] << shipment
      when "declined" || "finished"
        results[:finished] << shipment
      when "ignored"
        results[:ignored] << shipment
      end
    end
    response_handler(results)
  end
end
