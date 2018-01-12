class ContactsController < ApplicationController
  include Response
  before_action :require_login

  def show
    contact = Contact.find(params[:id])
    scs = contact.shipment_contacts
    shipments = []
    scs.each do |s|
      shipments.push(s.shipment)
    end
    location = contact.location
    response_handler({contact: contact, shipments: shipments, location: location})
  end
  private
  def require_login
    unless user_signed_in? && current_user
      redirect_to root_path
    end
  end
end
