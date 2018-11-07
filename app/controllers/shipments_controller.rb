# frozen_string_literal: true

class ShipmentsController < ApplicationController
  include ShippingTools
  include MongoTools

  skip_before_action :require_non_guest_authentication!

  def index
    current_user.tenant.quotation_tool ? get_quote_index : get_booking_index
  end

  def delta_page_handler
    case params[:target]
    when 'requested'
      shipment_association = current_user.shipments.requested
                                         .order(booking_placed_at: :desc)
                                         .paginate(page: params[:page], per_page: per_page)
    when 'open'
      shipment_association = current_user.shipments.open
                                         .order(booking_placed_at: :desc)
                                         .paginate(page: params[:page], per_page: per_page)
    when 'rejected'
      shipment_association = current_user.shipments.rejected
                                         .order(booking_placed_at: :desc)
                                         .paginate(page: params[:page], per_page: per_page)
    when 'finished'
      shipment_association = current_user.shipments.finished
                                         .order(booking_placed_at: :desc)
                                         .paginate(page: params[:page], per_page: per_page)
    when 'archived'
      shipment_association = current_user.shipments.archived
                                         .order(booking_placed_at: :desc)
                                         .paginate(page: params[:page], per_page: per_page)
    when 'quoted'
      shipment_association = current_user.shipments.quoted
                                         .order(booking_placed_at: :desc)
                                         .paginate(page: params[:page], per_page: per_page)
    end
    per_page = params.fetch(:per_page, 4).to_f
    shipments = shipment_association.map(&:with_address_index_json)

    response_handler(
      shipments: shipments,
      num_shipment_pages: shipment_association.total_pages,
      target: params[:target],
      page: params[:page]
    )
  end

  def new
  end

  def test_email
    tenant_notification_email(current_user, Shipment.where(status: 'requested').first)
  end

  def search_shipments
    filterific_params = {
      user_search: params[:query]
    }
    filters = [
      :user_search
    ]
    case params[:target]
    when 'requested'
      shipment_association = current_user.shipments.requested.order(booking_placed_at: :desc)
    when 'open'
      shipment_association = current_user.shipments.open.order(booking_placed_at: :desc)
    when 'finished'
      shipment_association = current_user.shipments.finished.order(booking_placed_at: :desc)
    when 'rejected'
      shipment_association = current_user.shipments.rejected.order(booking_placed_at: :desc)
    when 'archived'
      shipment_association = current_user.shipments.archived.order(booking_placed_at: :desc)
    when 'quoted'
      shipment_association = current_user.shipments.quoted.order(booking_placed_at: :desc)
    end
    per_page = params.fetch(:per_page, 4).to_f

    (filterrific = initialize_filterrific(
      shipment_association,
      filterific_params,
      available_filters: filters,
      sanitize_params: true
    )) || return
    shipments = filterrific.find.paginate(page: params[:page], per_page: per_page)

    response_handler(
      shipments: shipments.map(&:with_address_index_json),
      num_shipment_pages: shipment.total_pages,
      target: params[:target],
      page: params[:page]
    )
  end

  # Uploads document and returns Document item
  def upload_document
    @shipment = Shipment.find(params[:shipment_id])
    if params[:file]
      @doc = Document.create!(
        shipment: @shipment,
        text: params[:file].original_filename.gsub(/[^0-9A-Za-z.\-]/, '_'),
        doc_type: params[:type],
        user: current_user,
        tenant: current_user.tenant,
        file: params[:file]
      )

      @doc.as_json.merge(
        signed_url: rails_blob_url(@doc.file, disposition: 'attachment')
      )
    end

    response_handler(@doc)
  end

  def show
    shipment = Shipment.find(params[:id])

    cargo_item_types = shipment.cargo_item_types.each_with_object({}) do |cargo_item_type, return_h|
      return_h[cargo_item_type.id] = cargo_item_type
    end

    contacts = shipment.shipment_contacts.map do |sc|
      { contact: sc.contact, type: sc.contact_type, address: sc.contact.address } if sc.contact
    end

    documents = shipment.documents.map do |doc|
      doc.as_json.merge(
        signed_url: rails_blob_url(doc.file, disposition: 'attachment')
      )
    end

    shipment_as_json = shipment.with_address_options_json

    response_handler(
      shipment: shipment_as_json,
      cargoItems: shipment.cargo_items,
      containers: shipment.containers,
      aggregatedCargo: shipment.aggregated_cargo,
      contacts: contacts,
      documents: documents,
      cargoItemTypes: cargo_item_types
    )
  end

  def get_booking_index
    response = Rails.cache.fetch("#{requested_shipments.cache_key}/shipment_index", expires_in: 12.hours) do
      per_page = params.fetch(:per_page, 4).to_f
      r_shipments = requested_shipments.order(booking_placed_at: :desc).paginate(page: params[:requested_page], per_page: per_page)
      o_shipments = open_shipments.order(booking_placed_at: :desc).paginate(page: params[:open_page], per_page: per_page)
      f_shipments = finished_shipments.order(booking_placed_at: :desc).paginate(page: params[:finished_page], per_page: per_page)
      rj_shipments = rejected_shipments.order(booking_placed_at: :desc).paginate(page: params[:rejected_page], per_page: per_page)
      a_shipments = archived_shipments.order(booking_placed_at: :desc).paginate(page: params[:archived_page], per_page: per_page)

      num_pages = {
        finished: f_shipments.total_pages,
        requested: r_shipments.total_pages,
        open: o_shipments.total_pages,
        rejected: rj_shipments.total_pages,
        archived: a_shipments.total_pages
      }
      {
        requested: r_shipments.map(&:with_address_index_json),
        open: o_shipments.map(&:with_address_index_json),
        finished: f_shipments.map(&:with_address_index_json),
        rejected: rj_shipments.map(&:with_address_index_json),
        archived: a_shipments.map(&:with_address_index_json),
        pages: {
          open: params[:open_page],
          finished: params[:finished_page],
          requested: params[:requested_page],
          rejected: params[:rejected_page],
          archived: params[:archived_page]
        },
        num_shipment_pages: num_pages
      }
    end
    response_handler(response)
  end

  def get_quote_index

    response = Rails.cache.fetch("#{quoted_shipments.cache_key}/shipment_index", expires_in: 12.hours) do
      per_page = params.fetch(:per_page, 4).to_f
      quoted = quoted_shipments.order(updated_at: :desc)
                               .paginate(page: params[:quoted_page], per_page: per_page)
      num_pages = {
        quoted: quoted.total_pages
      }
      {
        quoted: quoted.map(&:with_address_index_json),
        pages: {
          quoted: params[:quoted_page]
        },
        num_shipment_pages: num_pages
      }
    end
    response_handler(response)
  end

  def requested_shipments
    @requested_shipments ||= current_user.shipments.requested
  end

  def quoted_shipments
    @quoted_shipments ||= current_user.shipments.quoted
  end

  def open_shipments
    @open_shipments ||= current_user.shipments.open
  end

  def rejected_shipments
    @rejected_shipments ||= current_user.shipments.rejected
  end

  def archived_shipments
    @archived_shipments ||= current_user.shipments.archived
  end

  def finished_shipments
    @finished_shipments ||= current_user.shipments.finished
  end
end
