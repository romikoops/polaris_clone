# frozen_string_literal: true

class ContactsController < ApplicationController
  include Response
  include ActionController::Helpers

  def index
    response_handler(
      pagination_options.merge(
        contacts: paginated_contacts.map(&:as_options_json),
        numContactPages: paginated_contacts.total_pages
      )
    )
  end

  def show
    contact = Legacy::Contact.find(params[:id])
    shipments = Legacy::ShipmentDecorator.decorate_collection(
      Legacy::Shipment.where(id: contact.shipment_contacts.select(:shipment_id))
    ).map(&:legacy_address_json)
    address = contact.address
    response_handler(contact: contact, shipments: shipments, address: address.to_custom_hash)
  end

  def update
    update_data = JSON.parse(params[:update])

    contact = Contact.find_by(id: params[:id], sandbox: @sandbox)
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
    edited_contact_data[:sandbox] = @sandbox
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
    edited_contact_address[:sandbox] = @sandbox
    edited_contact_address[:zip_code] = update_data['zipCode']
    edited_contact_address[:country] = Country.geo_find_by_name(update_data['country'])
    loc.update_attributes(edited_contact_address)
    edited_contact_data[:address_id] = loc.id
    edited_contact_data[:user_id] = organization_user.id
    contact.update_attributes(edited_contact_data)
    contact.save!
    response_handler(contact.as_options_json)
  end

  def search_contacts
    response_handler(
      pagination_options.merge(
        contacts: paginated_contacts.map(&:as_options_json),
        numContactPages: paginated_contacts.total_pages
      )
    )
  end

  def booking_process
    response_contacts = paginated_contacts.map do |contact|
      {
        address: contact.address.try(:to_custom_hash) || {},
        contact: contact.attributes
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    response_handler(
      pagination_options.merge(
        contacts: response_contacts,
        numContactPages: paginated_contacts.total_pages
      )
    )
  end

  def update_contact_address
    data = JSON.parse(params[:address])
    loc = Address.find_by(id: data['id'], sandbox: @sandbox)
    data['country'] = Country.geo_find_by_name(data['country'])
    data.delete('id')
    data.delete('address_type')
    loc.update_attributes(data)
    loc.save!
    response_handler(loc.to_custom_hash)
  end

  def delete_contact_address
    loc = Address.find_by(id: params[:id], sandbox: @sandbox)
    loc.destroy!
    response_handler({})
  end

  def create
    contact = Contact.new(create_contact_params)
    contact.address = Address.create!(create_contact_address_params)

    contact.save!

    response_handler(contact.as_options_json)
  end

  def is_valid
    valid = !Contact.where(user: organization_user, email: params[:email], sandbox: @sandbox).empty?
    response_handler(email: valid)
  end

  private

  def search_params
    params.permit(
      :query,
      :page,
      :per_page
    )
  end

  def contacts
    @contacts ||= Contact.where(user: organization_user, sandbox: @sandbox).order(updated_at: :desc)
  end

  def pagination_options
    {
      page: current_page,
      per_page: params[:per_page]&.to_f
    }.compact
  end

  def paginated_contacts
    return contacts.paginate(pagination_options) if search_params[:query].blank?

    contacts.contact_search(search_params[:query]).paginate(pagination_options)
  end

  def current_page
    params[:page]&.to_i || 1
  end

  def contact_params
    JSON.parse(params[:new_contact])
  end

  def create_contact_params
    {
      first_name: contact_params['firstName'],
      last_name: contact_params['lastName'],
      company_name: contact_params['companyName'],
      phone: contact_params['phone'],
      email: contact_params['email'],
      user: organization_user
    }
  end

  def create_contact_address_params
    {
      street_number: contact_params['number'] || contact_params['streetNumber'],
      street: contact_params['street'],
      city: contact_params['city'],
      zip_code: contact_params['zipCode'],
      sandbox: @sandbox,
      country: Country.find_by_name(contact_params['country'])
    }
  end
end
