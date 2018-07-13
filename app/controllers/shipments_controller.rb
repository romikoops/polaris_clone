# frozen_string_literal: true

class ShipmentsController < ApplicationController
  include ShippingTools
  include MongoTools

  skip_before_action :require_non_guest_authentication!

  def index
    @shipper = current_user
    requested_shipments = Shipment.where(
      status:    %w[requested requested_by_unconfirmed_account],
      tenant_id: current_user.tenant_id
    )
    open_shipments = Shipment.where(
      status:    %w[in_progress confirmed],
      tenant_id: current_user.tenant_id
    )
    finished_shipments = Shipment.where(status: "finished", tenant_id: current_user.tenant_id)
    @requested_shipments = requested_shipments.map{|shipment| shipment.with_address_options_json}
    @open_shipments = open_shipments.map{|shipment| shipment.with_address_options_json}
    @finished_shipments = finished_shipments.map{|shipment| shipment.with_address_options_json}
    response_handler(
      requested: @requested_shipments,
      open:      @open_shipments,
      finished:  @finished_shipments
    )
  end

  def new; end

  def test_email
    tenant_notification_email(current_user, Shipment.first)
  end



  # Uploads document and returns Document item
  def upload_document
    @shipment = Shipment.find(params[:shipment_id])
    @doc
    if params[:file]
      @doc = create_document(params[:file], @shipment, params[:type], current_user)
      tmp = @doc.as_json
      tmp["signed_url"] = @doc.get_signed_url
    end
    response_handler(tmp)
  end

  def show
    shipment = Shipment.find(params[:id])

    cargo_item_types = shipment.cargo_item_types.each_with_object({}) do |cargo_item_type, return_h|
      return_h[cargo_item_type.id] = cargo_item_type
    end

    contacts = shipment.shipment_contacts.map do |sc|
      if sc.contact
        { contact: sc.contact, type: sc.contact_type, location: sc.contact.location }
      end
    end

    documents = shipment.documents.map do |doc|
      tmp_doc = doc.as_json
      tmp_doc["signed_url"] = doc.get_signed_url
      tmp_doc
    end

    shipment_as_json = shipment.with_address_options_json
    response_handler(
      shipment:        shipment_as_json,
      cargoItems:      shipment.cargo_items,
      containers:      shipment.containers,
      aggregatedCargo: shipment.aggregated_cargo,
      contacts:        contacts,
      documents:       documents,
      cargoItemTypes:  cargo_item_types
    )
  end

  def get_shipper_pdf
    get_shipment_pdf(params)
  end
end
