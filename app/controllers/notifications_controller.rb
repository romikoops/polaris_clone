class NotificationsController < ApplicationController
  skip_before_action :require_non_guest_authentication!
  include NotificationTools
  include Response
  def index
    if current_user && current_user.role.name == "shipper"
      messages = get_messages_for_user(current_user)
      response_handler(messages)
    elsif current_user && current_user.role.name.include?("admin")
      messages = get_messages_for_admin(current_user)
      response_handler(messages)
    else
      response_handler({conversations: {}})
    end
   
  end

  def send_message
    message = params[:message].as_json
    isAdmin = current_user.role.name.include?("admin")
    resp = add_message_to_convo(current_user, message, isAdmin)
    response_handler(resp)
  end
  def mark_as_read
    messages = get_messages_for_user(current_user)
    messages["conversations"][params[:shipmentRef]]["messages"].each do |msg|
      msg["read"] = true
    end
    update_convo(current_user, messages)
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
    @schedules = []
    @shipment.schedule_set.each do |ss|
      @schedules.push(Schedule.find(ss['id']))
    end
    hubs[:startHub] = Hub.find(@schedules.first.hub_route_key.split("-")[0].to_i)
    hubs[:endHub] = Hub.find(@schedules.last.hub_route_key.split("-")[1].to_i)
    @documents = []
    @shipment.documents.each do |doc|
      tmp = doc.as_json
      tmp["signed_url"] =  doc.get_signed_url
      @documents << tmp
    end
    resp = {shipment: @shipment, cargoItems: @cargo_items, containers: @containers, contacts: @contacts, documents: @documents, schedules: @schedules, hubs: hubs}
    response_handler(resp)
  end
end
