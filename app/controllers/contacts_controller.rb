# frozen_string_literal: true

class ContactsController < ApplicationController
  include Response
  before_action :require_login

  def index
    contacts = current_user.contacts
    paginated_contacts = contacts.paginate(page: params[:page]).map(&:as_options_json)
    response_handler(contacts: paginated_contacts, numContactPages: (contacts.length / (params[:per_page] || 6).to_f).ceil)
  end

  def show
    contact = Contact.find(params[:id])
    scs = contact.shipment_contacts
    shipments = []
    scs.each do |s|
      tmp_shipment = s.shipment
      next unless tmp_shipment
      shipments.push(tmp_shipment.with_address_options_json)
    end
    location = contact.location
    response_handler(contact: contact, shipments: shipments, location: location)
  end

  def update
    update_data = JSON.parse(params[:update])

    contact = Contact.find(params[:id])
    loc = contact.location || Location.new
    update_data.delete('id')
    update_data.delete('userId')
    update_data.delete('locationId')

    edited_contact_data = {}
    edited_contact_location = {}
    edited_contact_data[:first_name] = update_data['firstName']
    edited_contact_data[:last_name] = update_data['lastName']
    edited_contact_data[:company_name] = update_data['companyName']
    edited_contact_data[:phone] = update_data['phone']
    edited_contact_data[:email] = update_data['email']
    if !update_data['geocodedAddress']
      edited_contact_location[:geocoded_address] =
        "#{update_data['street']} #{update_data['number'] || update_data['streetNumber']}, #{update_data['city']}, #{update_data['zipCode']}, #{update_data['country']}"
    else
      edited_contact_location[:geocoded_address] = update_data['geocodedAddress']
    end
    edited_contact_location[:street_number] = update_data['number'] || update_data['streetNumber']
    edited_contact_location[:street] = update_data['street']
    edited_contact_location[:street_address] = "#{update_data['street']} #{update_data['number'] || update_data['streetNumber']}"
    edited_contact_location[:city] = update_data['city']
    edited_contact_location[:zip_code] = update_data['zipCode']
    edited_contact_location[:country] = Country.geo_find_by_name(update_data['country'])
    loc.update_attributes(edited_contact_location)
    edited_contact_data[:location_id] = loc.id
    edited_contact_data[:user_id] = current_user.id
    contact.update_attributes(edited_contact_data)
    contact.save!
    response_handler(contact.as_options_json)
  end

  def search_contacts
    filterific_params = {
      contacts_query: params[:query]
    }

    (filterrific = initialize_filterrific(
      current_user.contacts,
      filterific_params,
      available_filters: [
        :contacts_query
      ],
      sanitize_params:   true
    )) || return
    per_page = params[:per_page] ? params[:per_page].to_f : 4.to_f
    contacts_results = filterrific.find
    contacts = contacts_results.paginate(page: params[:page], per_page: per_page).map(&:as_options_json)
    response_handler(
      contacts:          contacts,
      numContactPages: (contacts_results.count / per_page).ceil,
      page:               params[:page]
    )
  end

  def update_contact_address
    data = JSON.parse(params[:address])
    loc = Location.find(data['id'])
    data.delete('id')
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
    ncd[:first_name] = contact_data['firstName']
    ncd[:last_name] = contact_data['lastName']
    ncd[:company_name] = contact_data['companyName']
    ncd[:phone] = contact_data['phone']
    ncd[:email] = contact_data['email']
    ncd[:alias] = true

    ncl[:street_number] = contact_data['number']
    ncl[:street] = contact_data['street']
    ncl[:city] = contact_data['city']
    ncl[:zip_code] = contact_data['zipCode']
    ncl[:country] = Country.geo_find_by_name(contact_data['country'])

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
    ncd[:first_name] = contact_data['firstName']
    ncd[:last_name] = contact_data['lastName']
    ncd[:company_name] = contact_data['companyName']
    ncd[:phone] = contact_data['phone']
    ncd[:email] = contact_data['email']

    ncl[:street_number] = contact_data['number'] || contact_data['streetNumber']
    ncl[:street] = contact_data['street']
    ncl[:city] = contact_data['city']
    ncl[:zip_code] = contact_data['zipCode']
    ncl[:country] = Country.find_by_name(contact_data['country'])

    new_loc = Location.create!(ncl)
    ncd[:location_id] = new_loc.id
    contact = current_user.contacts.create!(ncd)
    response_handler(contact)
  end

  def is_valid
    valid = !current_user.contacts.where(email: params[:email]).empty?
    response_handler(email: valid)
  end

  private

  def require_login
    unless user_signed_in? && current_user && current_user.tenant_id == Tenant.find_by_subdomain(params[:subdomain_id]).id
      redirect_to root_path
    end
  end
end
