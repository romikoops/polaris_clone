# frozen_string_literal: true

class ContactsController < ApplicationController
  include Response
  before_action :require_login

  def show
    contact = Contact.find(params[:id])
    scs = contact.shipment_contacts
    shipments = []
    scs.each do |s|
      tmp_shipment = s.shipment
      next if !tmp_shipment
      shipments.push(tmp_shipment.with_address_options_json)
    end
    location = contact.location
    response_handler(contact: contact, shipments: shipments, location: location)
  end

  def update_contact
    update_data = JSON.parse(params[:update])
    contact = Contact.find(params[:id])
    loc = Location.find(update_data["locationId"])
    update_data.delete("id")
    update_data.delete("locationId")

    byebug
    edited_contact_data = {}
    edited_contact_location = {}
    edited_contact_data[:first_name] = update_data["firstName"]
    edited_contact_data[:last_name] = update_data["lastName"]
    edited_contact_data[:company_name] = update_data["companyName"]
    edited_contact_data[:phone] = update_data["phone"]
    edited_contact_data[:email] = update_data["email"]
    edited_contact_data[:alias] = true
    edited_contact_data[:user_id] = update_data["userId"]

    edited_contact_location[:street_number] = update_data["number"] || update_data["streetNumber"]
    edited_contact_location[:street] = update_data["street"]
    edited_contact_location[:city] = update_data["city"]
    edited_contact_location[:zip_code] = update_data["zipCode"]
    edited_contact_location[:country] = Country.geo_find_by_name(update_data["country"])
    byebug
    loc.update_attributes(edited_contact_location)
    edited_contact_data[:location_id] = loc.id
    contact.update_attributes(edited_contact_data)
    byebug
    contact.save!
    response_handler(contact)
  end

  def update_contact_address
    data = JSON.parse(params[:address])
    loc = Location.find(data["id"])
    data.delete("id")
    loc.update_attributes(data)
    loc.save!
    response_handler(loc)
  end

  def delete_contact_address
    loc = Location.find(params[:id])
    loc.destroy!
    response_handler({})
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
    ncl[:country] = Country.geo_find_by_name(contact_data["country"])

    new_loc = Location.create!(ncl)
    ncd[:location_id] = new_loc.id
    contact = current_user.contacts.create!(ncd)
    response_handler(contact)
  end

  def delete_alias
    contact = Contact.find(params[:id])
    if contact.user_id == current_user.id
      contact.destroy
      response_handler(params[:id])
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

    ncl[:street_number] = contact_data["number"] || contact_data["streetNumber"]
    ncl[:street] = contact_data["street"]
    ncl[:city] = contact_data["city"]
    ncl[:zip_code] = contact_data["zipCode"]
    ncl[:country] = Country.find_by_name(contact_data["country"])

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
