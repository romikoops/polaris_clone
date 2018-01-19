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

  def update_contact
    update_data = JSON.parse(params[:update])
    contact = Contact.find(params[:id])
    update_data.delete('id')
    contact.update_attributes(update_data)
    contact.save!
    response_handler(contact)

  end

  def new_alias
    contact_data = JSON.parse(params[:new_contact])
    ncd = {}
    ncl = {}
    ncd[:first_name] = contact_data["firstName"]
    ncd[:last_name] = contact_data["lastName"]
    ncd[:company_name] = contact_data["companyName"]
    ncd[:phone] = contact_data["phone"]
    ncd[:email] = contact_data["email"]
    ncd[:alias] = true

    ncl[:street_number] = contact_data["number"]
    ncl[:street] = contact_data["street"]
    ncl[:city] = contact_data["city"]
    ncl[:zip_code] = contact_data["zipCode"]
    ncl[:country] = contact_data["country"]

    new_loc = Location.create!(ncl)
    ncd[:location_id] = new_loc.id
    contact = current_user.contacts.create!(ncd)
    response_handler(contact)

  end

  def delete_alias
    contact = Contact.find(params[:id])
    if contact.shipper_id == current_user.id
      contact.destroy
      response_handler(true)
      else
      response_handler(false)  
    end 
  end

  def create
    contact_data = JSON.parse(params[:new_contact])
    ncd = {}
    ncl = {}
    ncd[:first_name] = contact_data["firstName"]
    ncd[:last_name] = contact_data["lastName"]
    ncd[:company_name] = contact_data["companyName"]
    ncd[:phone] = contact_data["phone"]
    ncd[:email] = contact_data["email"]

    ncl[:street_number] = contact_data["number"]
    ncl[:street] = contact_data["street"]
    ncl[:city] = contact_data["city"]
    ncl[:zip_code] = contact_data["zipCode"]
    ncl[:country] = contact_data["country"]

    new_loc = Location.create!(ncl)
    ncd[:location_id] = new_loc.id
    contact = current_user.contacts.create!(ncd)
    response_handler(contact)

  end

  private
  
  def require_login
    unless user_signed_in? && current_user && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
