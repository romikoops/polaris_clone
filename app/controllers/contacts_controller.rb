# frozen_string_literal: true

class ContactsController < ApplicationController
  include Response

  def index
    paginated_contacts = contacts.paginate(pagination_options)

    response_handler(
      pagination_options.merge(
        contacts: paginated_contacts.map(&:as_options_json),
        numContactPages: paginated_contacts.total_pages
      )
    )
  end

  def show
    contact = Contact.find(params[:id])
    scs = contact.shipment_contacts
    shipments = []
    scs.each do |s|
      tmp_shipment = s.shipment
      next unless tmp_shipment

      shipments.push(tmp_shipment.with_address_index_json)
    end
    address = contact.address
    response_handler(contact: contact, shipments: shipments, address: address.to_custom_hash)
  end

  def update
    update_data = JSON.parse(params[:update])

    contact = Contact.find(params[:id])
    loc = contact.address || Address.new
    update_data.delete('id')
    update_data.delete('userId')
    update_data.delete('addressId')

    edited_contact_data = {}
    edited_contact_address = {}
    edited_contact_data[:first_name] = update_data['firstName']
    edited_contact_data[:last_name] = update_data['lastName']
    edited_contact_data[:company_name] = update_data['companyName']
    edited_contact_data[:phone] = update_data['phone']
    edited_contact_data[:email] = update_data['email']
    if !update_data['geocodedAddress']
      edited_contact_address[:geocoded_address] =
        "#{update_data['street']} #{update_data['number'] || update_data['streetNumber']}, #{update_data['city']}, #{update_data['zipCode']}, #{update_data['country']}"
    else
      edited_contact_address[:geocoded_address] = update_data['geocodedAddress']
    end
    edited_contact_address[:street_number] = update_data['number'] || update_data['streetNumber']
    edited_contact_address[:street] = update_data['street']
    edited_contact_address[:street_address] = "#{update_data['street']} #{update_data['number'] || update_data['streetNumber']}"
    edited_contact_address[:city] = update_data['city']
    edited_contact_address[:zip_code] = update_data['zipCode']
    edited_contact_address[:country] = Country.geo_find_by_name(update_data['country'])
    loc.update_attributes(edited_contact_address)
    edited_contact_data[:address_id] = loc.id
    edited_contact_data[:user_id] = current_user.id
    contact.update_attributes(edited_contact_data)
    contact.save!
    response_handler(contact.as_options_json)
  end

  def search_contacts
    # TODO: Handle invalid query
    return if filterrific.nil?

    paginated_contacts = filterrific.find.paginate(pagination_options)

    response_handler(
      pagination_options.merge(
        contacts: paginated_contacts.map(&:as_options_json),
        numContactPages: paginated_contacts.total_pages
      )
    )
  end

  def update_contact_address
    data = JSON.parse(params[:address])
    loc = Address.find(data['id'])
    data['country'] = Country.geo_find_by_name(data['country'])
    data.delete('id')
    loc.update_attributes(data)
    loc.save!
    response_handler(loc.to_custom_hash)
  end

  def delete_contact_address
    loc = Address.find(params[:id])
    loc.destroy!
    response_handler({})
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

    new_loc = Address.create!(ncl)
    ncd[:address_id] = new_loc.id
    contact = current_user.contacts.create!(ncd)
    response_handler(contact.as_options_json)
  end

  def is_valid
    valid = !current_user.contacts.where(email: params[:email]).empty?
    response_handler(email: valid)
  end

  private

  def contacts
    @contacts ||= current_user.contacts.order(updated_at: :desc)
  end

  def pagination_options
    {
      page: current_page,
      per_page: params[:per_page]&.to_f
    }.compact
  end

  def filterrific
    @filterrific ||= initialize_filterrific(
      contacts,
      { contacts_query: params[:query] },
      available_filters: %i(contacts_query),
      sanitize_params: true
    )
  end

  def current_page
    params[:page]&.to_i || 1
  end
end
