# frozen_string_literal: true

require "bigdecimal"
require "net/http"

class ShippingTools
  InternalError = Class.new(StandardError)
  ShipmentNotFound = Class.new(StandardError)
  DataMappingError = Class.new(StandardError)
  ContactsRedundancyError = Class.new(StandardError)

  attr_reader :current_organization

  def initialize
    @current_organization = ::Organizations::Organization.current
  end

  def create_shipment(details, current_user)
    scope = OrganizationManager::ScopeService.new(
      target: current_user,
      organization: current_organization
    ).fetch

    raise ApplicationError::NotLoggedIn if scope[:closed_shop] && current_user.blank?

    load_type = details["loadType"].underscore
    direction = details["direction"]

    shipment = Legacy::Shipment.new(
      user: current_user,
      status: "booking_process_started",
      load_type: load_type,
      direction: direction,
      organization: current_organization
    )
    shipment.save!

    routes_data = Api::Routing::LegacyRoutingService.routes(
      organization: current_organization,
      user: current_user,
      scope: scope,
      load_type: load_type
    )
    cargo_classes = shipment.lcl? ? ["lcl"] : Legacy::Container::CARGO_CLASSES
    max_dimensions = Legacy::MaxDimensionsBundle.unit
      .where(organization: current_organization, cargo_class: cargo_classes)
      .to_max_dimensions_hash
    max_aggregate_dimensions = Legacy::MaxDimensionsBundle.aggregate
      .where(organization: current_organization, cargo_class: cargo_classes)
      .to_max_dimensions_hash

    {
      shipment: shipment,
      routes: routes_data[:route_hashes],
      lookup_tables_for_routes: routes_data[:look_ups],
      cargo_item_types: Legacy::TenantCargoItemType.where(
        organization: current_organization
      ).map(&:cargo_item_type),
      max_dimensions: max_dimensions,
      max_aggregate_dimensions: max_aggregate_dimensions,
      last_available_date: Time.zone.today
    }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def contact_address_params(resource)
    resource.require(:address)
      .permit(:street, :streetNumber, :zipCode, :city, :country)
      .to_h.deep_transform_keys(&:underscore)
  end

  def contact_params(resource, address_id = nil)
    resource.require(:contact)
      .permit(:companyName, :firstName, :lastName, :email, :phone)
      .to_h.deep_transform_keys(&:underscore)
      .merge(address_id: address_id)
  end

  def shipment_documents(shipment:)
    documents = Hash.new { |h, k| h[k] = [] }
    shipment.files.each do |doc|
      documents[doc.doc_type] << doc
    end
  end

  def default_currency(user:)
    OrganizationManager::ScopeService.new(
      target: user,
      organization: current_organization
    ).fetch(:default_currency)
  end

  def search_contacts(contact_params, current_user)
    contact_email = contact_params["email"]
    existing_contact = Contact.where(user: current_user, email: contact_email).first
    existing_contact || Contact.create(contact_params.merge(user: current_user))
  end
end
