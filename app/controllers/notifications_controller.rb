class NotificationsController < ApplicationController
  include NotificationTools
  include Response
  def index
    if current_user
      messages = get_messages_for_user(current_user)
      response_handler(messages)
    else
      response_handler({conversations: {}})
    end
   
  end

  def send_message
    message = params[:message].as_json
    resp = add_message_to_convo(current_user, message, false)
    response_handler(resp)
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
    @schedules = []
    @shipment.schedule_set.each do |ss|
      @schedules.push(Schedule.find(ss['id']))
    end
    @documents = []
    @shipment.documents.each do |doc|
      tmp = doc.as_json
      tmp["signed_url"] =  doc.get_signed_url
      @documents << tmp
    end
    resp = {shipment: @shipment, cargoItems: @cargo_items, containers: @containers, contacts: @contacts, documents: @documents, schedules: @schedules}
    response_handler(resp)
  end
end
