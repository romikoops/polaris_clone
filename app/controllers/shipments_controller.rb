# frozen_string_literal: true

class ShipmentsController < ApplicationController
  def index
    quotation_tool? ? get_quote_index : get_booking_index
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
      shipments: shipment_table_list(shipments: shipments),
      num_shipment_pages: shipments.total_pages,
      target: params[:target],
      page: params[:page]
    )
  end

  def new
  end

  def test_email
    tenant_notification_email(organization_user, Shipment.where(status: 'requested').first)
  end

  def search_shipments
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

    results = shipment_association.index_search(params[:query])
    per_page = params.fetch(:per_page, 4).to_f
    shipments = results.order(:updated_at).paginate(page: params[:page], per_page: per_page)

    response_handler(
      shipments: shipment_table_list(shipments: shipments),
      num_shipment_pages: shipments.total_pages,
      target: params[:target],
      page: params[:page]
    )
  end

  # Uploads document and returns Document item
  def upload_document
    @shipment = Shipment.find_by(id: params[:shipment_id])
    if params[:file]
      document = Legacy::File.create!(
        shipment: @shipment,
        text: params[:file].original_filename.gsub(/[^0-9A-Za-z.\-]/, '_'),
        doc_type: params[:type],
        user: organization_user,
        organization: current_organization,
        file: params[:file]
      )

      document_with_url = document.as_json.merge(
        signed_url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: 'attachment')
      )
    end

    response_handler(document_with_url)
  end

  def update_user
    Shipment.find_by(id: update_user_params[:id]).update(user: organization_user)
  end

  def show # rubocop:disable Metrics/AbcSize
    @shipment = Shipment.find_by(id: params[:id])
    cargo_item_types = @shipment.cargo_item_types.each_with_object({}) do |cargo_item_type, return_h|
      return_h[cargo_item_type.id] = cargo_item_type
    end

    contacts = @shipment.shipment_contacts.map do |sc|
      { contact: sc.contact, type: sc.contact_type, address: sc.contact.address } if sc.contact
    end

    documents = @shipment.files.select { |doc| doc.file.attached? }.map do |doc|
      doc.as_json.merge(
        signed_url: Rails.application.routes.url_helpers.rails_blob_url(doc.file, disposition: 'attachment')
      )
    end
    charge_breakdown = @shipment.charge_breakdowns.selected
    exchange_rates = ResultFormatter::ExchangeRateService.new(tender: charge_breakdown.tender).perform

    response_handler(
      shipment: shipment_as_json,
      cargoItems: @shipment.cargo_items.map(&:with_cargo_type),
      containers: @shipment.containers,
      aggregatedCargo: @shipment.aggregated_cargo,
      contacts: contacts,
      documents: documents,
      cargoItemTypes: cargo_item_types,
      exchange_rates: exchange_rates
    )
  end

  def get_booking_index # rubocop:disable Metrics/AbcSize, Naming/AccessorMethodName, Metrics/MethodLength
    response = Rails.cache.fetch("#{requested_shipments.cache_key}/shipment_index", expires_in: 12.hours) do # rubocop:disable Metrics/BlockLength
      per_page = params.fetch(:per_page, 4).to_f
      r_shipments = requested_shipments
                    .order(booking_placed_at: :desc)
                    .paginate(page: params[:requested_page], per_page: per_page)
      o_shipments = open_shipments
                    .order(booking_placed_at: :desc)
                    .paginate(page: params[:open_page], per_page: per_page)
      f_shipments = finished_shipments
                    .order(booking_placed_at: :desc)
                    .paginate(page: params[:finished_page], per_page: per_page)
      rj_shipments = rejected_shipments
                     .order(booking_placed_at: :desc)
                     .paginate(page: params[:rejected_page], per_page: per_page)
      a_shipments = archived_shipments
                    .order(booking_placed_at: :desc)
                    .paginate(page: params[:archived_page], per_page: per_page)

      num_pages = {
        finished: f_shipments.total_pages,
        requested: r_shipments.total_pages,
        open: o_shipments.total_pages,
        rejected: rj_shipments.total_pages,
        archived: a_shipments.total_pages
      }
      {
        requested: shipment_table_list(shipments: r_shipments),
        open: shipment_table_list(shipments: o_shipments),
        finished: shipment_table_list(shipments: f_shipments),
        rejected: shipment_table_list(shipments: rj_shipments),
        archived: shipment_table_list(shipments: a_shipments),
        pages: {
          open: params[:open_page],
          finished: params[:finished_page],
          requested: params[:requested_page],
          rejected: params[:rejected_page],
          archived: params[:archived_page]
        },
        nexuses: {
          open: {
            origin_nexuses: Nexus.where(id: organization_user_shipments.open.distinct.select(:origin_nexus_id)),
            destination_nexuses: Nexus.where(
              id: organization_user_shipments.open.distinct.select(:destination_nexus_id)
            )
          },
          requested: {
            origin_nexuses: Nexus.where(id: organization_user_shipments.requested.distinct.select(:origin_nexus_id)),
            destination_nexuses: Nexus.where(
              id: organization_user_shipments.requested.distinct.select(:destination_nexus_id)
            )
          },
          rejected: {
            origin_nexuses: Nexus.where(id: organization_user_shipments.rejected.distinct.select(:origin_nexus_id)),
            destination_nexuses: Nexus.where(
              id: organization_user_shipments.rejected.distinct.select(:destination_nexus_id)
            )
          },
          finished: {
            origin_nexuses: Nexus.where(id: organization_user_shipments.finished.distinct.select(:origin_nexus_id)),
            destination_nexuses: Nexus.where(
              id: organization_user_shipments.finished.distinct.select(:destination_nexus_id)
            )
          },
          archived: {
            origin_nexuses: Nexus.where(id: organization_user_shipments.archived.distinct.select(:origin_nexus_id)),
            destination_nexuses: Nexus.where(
              id: organization_user_shipments.archived.distinct.select(:destination_nexus_id)
            )
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
        quoted: shipment_table_list(shipments: quoted),
        pages: {
          quoted: params[:quoted_page]
        },
        num_shipment_pages: num_pages
      }
    end
    response_handler(response)
  end

  def shipment_as_json
    hidden_args = Pdf::HiddenValueService.new(user: @shipment.user).admin_args
    Legacy::ShipmentDecorator.new(@shipment, context: {scope: current_scope}).legacy_address_json(offer_args: hidden_args)
  end

  def filtered_user_shipments
    @filtered_user_shipments ||= begin
      @filtered_user_shipments = organization_user_shipments
      if params[:origin_nexus]
        @filtered_user_shipments = @filtered_user_shipments.where(origin_nexus_id: params[:origin_nexus].split(','))
      end

      if params[:destination_nexus]
        @filtered_user_shipments = @filtered_user_shipments
                                   .where(destination_nexus_id: params[:destination_nexus].split(','))
      end

      if params[:hub_type] && params[:hub_type] != ''

        hub_type_array = params[:hub_type].split(',')

        @filtered_user_shipments = @filtered_user_shipments.modes_of_transport(*hub_type_array)
      end

      @filtered_user_shipments
    end
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

  def update_user_params
    params.permit(:id)
  end

  def organization_user_shipments
    @organization_user_shipments ||= Legacy::Shipment.where(user: organization_user)
  end

  def shipment_table_list(shipments:)
    decorate_shipments(shipments: shipments).map(&:legacy_index_json)
  end
end
