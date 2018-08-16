# frozen_string_literal: true

class ShipmentsController < ApplicationController
  include ShippingTools
  include MongoTools

  skip_before_action :require_non_guest_authentication!

  def index
    @shipper = current_user
    requested_shipments = @shipper.shipments.where(
      status:    %w(requested requested_by_unconfirmed_account),
      tenant_id: current_user.tenant_id
    )
    open_shipments = @shipper.shipments.where(
      status:    %w(in_progress confirmed),
      tenant_id: current_user.tenant_id
    )
    finished_shipments = @shipper.shipments
      .where(status: "finished", tenant_id: current_user.tenant_id)
    r_shipments = requested_shipments
    o_shipments = open_shipments
    f_shipments = finished_shipments
    num_pages = {
      finished:  (f_shipments.count / 6.0).ceil,
      requested: (r_shipments.count / 6.0).ceil,
      open:      (o_shipments.count / 6.0).ceil
    }

    response_handler(
      requested:          requested_shipments
        .paginate(page: params[:requested_page])
        .map(&:with_address_options_json),
      open:               open_shipments
        .paginate(page: params[:open_page])
        .map(&:with_address_options_json),
      finished:           finished_shipments
        .paginate(page: params[:finished_page])
        .map(&:with_address_options_json),
      pages:              {
        open:      params[:open_page],
        finished:  params[:finished_page],
        requested: params[:requested_page]
      },
      num_shipment_pages: num_pages
    )
  end

  def delta_page_handler
    case params[:target]
    when "requested"
      shipment_association = current_user.shipments.requested
    when "open"
      shipment_association = current_user.shipments.open
    when "finished"
      shipment_association = current_user.shipments.finished
    end
    shipments = shipment_association
      .paginate(page: params[:page])
      .map(&:with_address_options_json)
    response_handler(
      shipments:          shipments,
      num_shipment_pages: (shipment_association.count / 6.0).ceil,
      target:             params[:target],
      page:               params[:page]
    )
  end

  def new; end

  def test_email
    tenant_notification_email(current_user, Shipment.where(status: "requested").first)
  end

  def search_shipments
    filterific_params = {
      user_search: params[:query]
    }
    filters = [
      :user_search
    ]
    case params[:target]
    when "requested"
      shipment_association = current_user.shipments.requested
    when "open"
      shipment_association = current_user.shipments.open
    when "finished"
      shipment_association = current_user.shipments.finished
    end

    (filterrific = initialize_filterrific(
      shipment_association,
      filterific_params,
      available_filters: filters,
      sanitize_params:   true
    )) || return
    shipments = filterrific.find.page(params[:page]).map(&:with_address_options_json)

    response_handler(
      shipments:          shipments,
      num_shipment_pages: (filterrific.find.count / 6.0).ceil,
      target:             params[:target],
      page:               params[:page]
    )
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
      { contact: sc.contact, type: sc.contact_type, location: sc.contact.location } if sc.contact
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
