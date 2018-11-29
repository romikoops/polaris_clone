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
      shipment_association = requested_shipments
                                         .order(booking_placed_at: :desc)
    when 'open'
      shipment_association = open_shipments
                                         .order(booking_placed_at: :desc)
    when 'rejected'
      shipment_association = rejected_shipments
                                         .order(booking_placed_at: :desc)
    when 'finished'
      shipment_association = finished_shipments
                                         .order(booking_placed_at: :desc)
    when 'archived'
      shipment_association = archived_shipments
                                         .order(booking_placed_at: :desc)
    when 'quoted'
      shipment_association = quoted_shipments
                                         .order(booking_placed_at: :desc)
    end
    per_page = params.fetch(:per_page, 4).to_f
    shipments = shipment_association.order(booking_placed_at: :desc).paginate(page: params[:page], per_page: per_page)

    response_handler(
      shipments: shipments.map(&:with_address_index_json),
      num_shipment_pages: shipments.total_pages,
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
      shipment_association = requested_shipments.order(booking_placed_at: :desc)
    when 'open'
      shipment_association = open_shipments.order(booking_placed_at: :desc)
    when 'finished'
      shipment_association = finished_shipments.order(booking_placed_at: :desc)
    when 'rejected'
      shipment_association = rejected_shipments.order(booking_placed_at: :desc)
    when 'archived'
      shipment_association = archived_shipments.order(booking_placed_at: :desc)
    when 'quoted'
      shipment_association = quoted_shipments.order(booking_placed_at: :desc)
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
      num_shipment_pages: shipments.total_pages,
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

    documents = shipment.documents.select { |doc| doc.file.attached? }.map do |doc|
      doc.as_json.merge(
        signed_url: Rails.application.routes.url_helpers.rails_blob_url(doc.file, disposition: 'attachment')
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
        nexuses: {
          open: {
            origin_nexuses: Nexus.where(id: current_user.shipments.open.distinct.pluck(:origin_nexus_id)),
            destination_nexuses: Nexus.where(id: current_user.shipments.open.distinct.pluck(:destination_nexus_id))
          },
          requested: {
            origin_nexuses: Nexus.where(id: current_user.shipments.requested.distinct.pluck(:origin_nexus_id)),
            destination_nexuses: Nexus.where(id: current_user.shipments.requested.distinct.pluck(:destination_nexus_id))
          },
          rejected: {
            origin_nexuses: Nexus.where(id: current_user.shipments.rejected.distinct.pluck(:origin_nexus_id)),
            destination_nexuses: Nexus.where(id: current_user.shipments.rejected.distinct.pluck(:destination_nexus_id))
          },
          finished: {
            origin_nexuses: Nexus.where(id: current_user.shipments.finished.distinct.pluck(:origin_nexus_id)),
            destination_nexuses: Nexus.where(id: current_user.shipments.finished.distinct.pluck(:destination_nexus_id))
          },
          archived: {
            origin_nexuses: Nexus.where(id: current_user.shipments.archived.distinct.pluck(:origin_nexus_id)),
            destination_nexuses: Nexus.where(id: current_user.shipments.archived.distinct.pluck(:destination_nexus_id))
          }
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

  def filtered_user_shipments
    return @filtered_user_shipments unless @filtered_user_shipments.nil?

    @filtered_user_shipments = current_user.shipments

    if params[:origin_nexus]
      @filtered_user_shipments = @filtered_user_shipments.where(origin_nexus_id: params[:origin_nexus].split(','))
    end

    if params[:destination_nexus]
      @filtered_user_shipments = @filtered_user_shipments.where(destination_nexus_id: params[:destination_nexus].split(','))
    end

    if params[:hub_type] && params[:hub_type] != ''

      hub_type_array = params[:hub_type].split(',')

      @filtered_user_shipments = @filtered_user_shipments.modes_of_transport(*hub_type_array)
    end

    @filtered_user_shipments
  end

  def requested_shipments
    @requested_shipments ||= filtered_user_shipments.requested
  end

  def quoted_shipments
    @quoted_shipments ||= filtered_user_shipments.quoted
  end

  def open_shipments
    @open_shipments ||= filtered_user_shipments.open
  end

  def rejected_shipments
    @rejected_shipments ||= filtered_user_shipments.rejected
  end

  def archived_shipments
    @archived_shipments ||= filtered_user_shipments.archived
  end

  def finished_shipments
    @finished_shipments ||= filtered_user_shipments.finished
  end
end
