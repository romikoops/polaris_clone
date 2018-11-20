# frozen_string_literal: true

class Admin::ShipmentsController < Admin::AdminBaseController
  before_action :do_for_show, only: :show
  include ShippingTools
  include NotificationTools

  def index
    current_user.tenant.quotation_tool ? get_quote_index : get_booking_index
  end

  def delta_page_handler
    case params[:target]
    when 'requested'
      shipment_association = tenant_shipment.requested
    when 'open'
      shipment_association = tenant_shipment.open
    when 'finished'
      shipment_association = tenant_shipment.finished
    when 'rejected'
      shipment_association = tenant_shipment.rejected
    when 'archived'
      shipment_association = tenant_shipment.archived
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

  def show
    response = Rails.cache.fetch("#{@shipment.cache_key}/view_shipment", expires_in: 12.hours) do
      prepare_response
      response_hash = {
        shipment: shipment_as_json,
        cargoItems: @cargo_items,
        containers: @containers,
        aggregatedCargo: @shipment.aggregated_cargo,
        contacts:        contacts,
        documents:       @documents,
        addresses:       addresses,
        cargoItemTypes:  cargo_item_types,
        accountHolder:   @shipment.user
      }
    end
    response_handler(
      response
    )
  end

  def search_shipments
    filterific_params = {
      user_search: params[:query]
    }
    case params[:target]
    when 'requested'
      shipment_association = requested_shipments
    when 'open'
      shipment_association = open_shipments
    when 'finished'
      shipment_association = finished_shipments
    when 'quoted'
      shipment_association = quoted_shipments
    when 'rejected'
      shipment_association = rejected_shipments
    when 'archived'
      shipment_association = archived_shipments
    end
    (filterrific = initialize_filterrific(
      shipment_association,
      filterific_params,
      available_filters: [
        :user_search
      ],
      sanitize_params: true
    )) || return
    per_page = params.fetch(:per_page, 4).to_f
    shipments = filterrific.find.paginate(page: params[:page], per_page: per_page)
    response_handler(
      shipments: shipments.map(&:with_address_index_json),
      num_shipment_pages: shipments.total_pages,
      target: params[:target],
      page: params[:page]
    )
  end

  def edit_price
    add_message_to_convo(update_shipment.user, price_message, true)
    response_handler(update_shipment.with_address_options_json)
  end

  def edit_service_price
    @shipment = Shipment.find(params[:id])
    new_price = Price.new(price_params)
    charge = edit_service_charge_breakdown.charge(params['charge_category'])
    charge.edited_price = new_price

    if charge.save
      update_charge_parent(charge)
      response_handler(@shipment.as_options_json)
    else
      response_handler(resp_error)
    end
  end

  def edit_time
    add_message_to_convo(update_schedule_shipment.user, schedule_message, true)
    response_handler(update_schedule_shipment.with_address_options_json)
  end

  def edit
    @shipment = Shipment.find(params[:id])
    @containers = Container.where(shipment_id: @shipment.id)
    @container_descriptions = CONTAINER_DESCRIPTIONS.invert
    @all_hubs = Address.all_hubs_prepared
  end

  def update
    @shipment = Shipment.find(params[:id])
    shipment_action if params[:shipment_action]
  end

  def document_action
    @document = Document.find(params[:id])
    @user = @document.user
    decide_document_action

    signed_url = @document.file.attached? && rails_blob_url(@document.file, disposition: 'attachment')
    response_handler(@document.as_json.merge(signed_url: signed_url))
  end

  def document_delete
    @document = Document.find(params[:id])
    @document.destroy

    response_handler(id: params[:id])
  end

  private

  def decide_document_action
    case params[:type]
    when 'approve'
      @document.approved = 'approved'
      @document.save!
      approved_document_message
      add_message_to_convo(@user, message, true)
    when 'reject'
      @document.approved = 'rejected'
      @document.save!
      rejected_document_message
      add_message_to_convo(@user, message, true)
    end
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
    response = Rails.cache.fetch("#{quoted_shipments.cache_key}/quote_index", expires_in: 12.hours) do
      per_page = params.fetch(:per_page, 4).to_f

      quoted = quoted_shipments.order(:updated_at)
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

  def resp_error
    ApplicationError.new(
      http_code: 400,
      code: SecureRandom.uuid,
      message: @shipments.errors.full_messages.join("\n")
    )
  end

  def update_charge_parent(edit_service_charge)
    unless edit_service_charge.parent.nil?
      edit_service_charge.parent.update_edited_price!
      edit_service_charge.parent.save!
    end
  end

  def edit_service_charge_breakdown
    @shipment.charge_breakdowns.selected
  end

  def shipment_action
    case params[:shipment_action]
    when 'accept'
      @shipment.accept!
      ShippingTools.shipper_confirmation_email(@shipment.user, @shipment)
      add_message_to_convo(@shipment.user, booking_accepted_message, true)
      response_handler(@shipment.with_address_options_json)
    when 'decline'
      @shipment.decline!
      add_message_to_convo(@shipment.user, booking_declined_message, true)
      response_handler(@shipment.with_address_options_json)
    when 'ignore'
      @shipment.ignore!
      add_message_to_convo(@shipment.user, booking_declined_message, true)
      response_handler(@shipment.with_address_options_json)
    when 'archive'
      @shipment.archive!
      response_handler(@shipment.with_address_options_json)
    when 'finished'
      @shipment.finish!
      response_handler(@shipment.with_address_options_json)
    else
      raise 'Unknown action!'
    end
  end

  def update_schedule_shipment
    if @shipment
      @shipment
    else
      shipment = Shipment.find(params[:id])
      shipment.planned_eta = new_eta
      shipment.planned_etd = new_etd
      shipment.planned_origin_drop_off_date = new_planned_origin_drop_off_date
      shipment.planned_destination_collection_date = new_planned_destination_collection_date
      shipment.planned_delivery_date = new_planned_delivery_date
      shipment.planned_pickup_date = new_planned_pickup_date
      shipment.save!
      @shipment = shipment
    end
  end

  def new_etd
    DateTime.parse(params[:timeObj]['newEtd'])
  end

  def new_eta
    DateTime.parse(params[:timeObj]['newEta'])
  end

  def new_planned_origin_drop_off_date
    return if params[:timeObj]['newOriginDropOffDate'] == 'Invalid date'

    DateTime.parse(params[:timeObj]['newOriginDropOffDate'])
  end

  def new_planned_destination_collection_date
    return if params[:timeObj]['newDestinationCollectionDate'] == 'Invalid date'

    DateTime.parse(params[:timeObj]['newDestinationCollectionDate'])
  end

  def new_planned_delivery_date
    return if params[:timeObj]['newDeliveryDate'] == 'Invalid date'

    DateTime.parse(params[:timeObj]['newDeliveryDate'])
  end

  def new_planned_pickup_date
    return if params[:timeObj]['newPickupDate'] == 'Invalid date'

    DateTime.parse(params[:timeObj]['newPickupDate'])
  end

  def update_shipment
    if @shipment
      @shipment
    else
      shipment = Shipment.find(params[:id])
      shipment.total_price = { value: params[:priceObj]['value'], currency: params[:priceObj]['currency'] }
      shipment.save!
      @shipment = shipment
    end
  end

  def prepare_response
    add_cargo_item_types
    add_hs_code
    populate_contacts
    populate_documents
  end

  def shipment_as_json
    @shipment.with_address_options_json
  end

  def addresses
    @addresses ||= {
      origin:      @shipment.origin_nexus,
      destination: @shipment.destination_nexus
    }
  end

  def options
    @options ||= {
      methods: %i(selected_offer mode_of_transport),
      include: [{ destination_nexus: {} },
                { origin_nexus: {} },
                { destination_hub: {} },
                { origin_hub: {} }]
    }
  end

  def populate_documents
    @documents = @shipment.documents.select { |doc| doc.file.attached? }.map do |doc|
      doc.as_json.merge(signed_url: rails_blob_url(doc.file, disposition: 'attachment'))
    end
  end

  def do_for_show
    @shipment = Shipment.find(params[:id])
    @cargo_items = @shipment.cargo_items
    @containers = @shipment.containers
  end

  def populate_contacts
    @shipment_contacts = @shipment.shipment_contacts
    @shipment_contacts.each do |sc|
      next unless sc.contact
      contacts.push(contact:  sc.contact,
                    type:     sc.contact_type,
                    address: sc.contact.address)
    end
  end

  def cargo_item_types
    @cargo_item_types ||= {}
  end

  def hs_codes
    @hs_codes ||= []
  end

  def add_cargo_item_types
    @cargo_items.each do |ci|
      if ci&.hs_codes
        ci.hs_codes.each do |hs|
          hs_codes << hs
        end
      end
      cargo_item_types[ci.cargo_item_type_id] = CargoItemType.find(ci.cargo_item_type_id)
    end
  end

  def add_hs_code
    @containers.each do |cn|
      next unless cn&.hs_codes

      cn.hs_codes.each do |hs|
        hs_codes << hs
      end
    end
  end

  def contacts
    @contacts ||= []
  end

  def tenant_shipment
    @shipment ||= Shipment.where(tenant_id: current_user.tenant_id)
  end

  def requested_shipments
    @requested_shipments ||= tenant_shipment.requested
  end

  def open_shipments
    @open_shipments ||= tenant_shipment.open
  end

  def quoted_shipments
    @quoted_shipments ||= tenant_shipment.quoted
  end

  def finished_shipments
    @finished_shipments ||= tenant_shipment.finished
  end

  def rejected_shipments
    @rejected_shipments ||= tenant_shipment.rejected
  end

  def archived_shipments
    @archived_shipments ||= tenant_shipment.archived
  end

  def documents
    @documents ||= {
      'requested_shipments' => Document.where(shipment_id: tenant_shipment.requested.select(:id)).group_by(&:doc_type),
      'open_shipments' => Document.where(shipment_id: tenant_shipment.open.select(:id)).group_by(&:doc_type),
      'finished_shipments' => Document.where(shipment_id: tenant_shipment.finished.select(:id)).group_by(&:doc_type),
      'rejected_shipments' => Document.where(shipment_id: tenant_shipment.rejected.select(:id)).group_by(&:doc_type),
      'archived_shipments' => Document.where(shipment_id: tenant_shipment.archived.select(:id)).group_by(&:doc_type)
    }
  end

  def shipment_params
    params.require(:shipment).permit(:total_price, :planned_pickup_date, :planned_delivery_date, :planned_origin_drop_off_date, :planned_destination_collection_date, :origin_id, :destination_id)
  end

  def price_params
    params.require(:price).permit(:value, :currency)
  end

  def approved_document_message
    {
      title: 'Document Approved',
      message: "Your document #{@document.text} was approved",
      shipmentRef: @document.shipment.imc_reference
    }
  end

  def rejected_document_message
    {
      title: 'Document Rejected',
      message: "Your document #{@document.text} was rejected: #{params[:text]}",
      shipmentRef: @document.shipment.imc_reference
    }
  end

  def price_message
    {
      title: 'Shipment Price Change',
      message: "Your shipment #{update_shipment.imc_reference} has an updated price. \
        Your new total is #{params[:priceObj]['currency']} #{params[:priceObj]['value']}. \
        For any issues, please contact your support agent.",
      shipmentRef: update_shipment.imc_reference
    }
  end

  def schedule_message
    {
      title: 'Shipment Schedule Updated',
      message: "Your shipment #{update_schedule_shipment.imc_reference} has an updated schedule. \
        Your new estimated departure is #{params[:timeObj]['newEtd']}, estimated to \
        arrive at #{params[:timeObj]['newEta']}. For any issues, please contact your \
        support agent.",
      shipmentRef: update_schedule_shipment.imc_reference
    }
  end

  def booking_accepted_message
    {
      title: 'Booking Accepted',
      message: "Your booking has been accepted! If you have any further questions or \
        edits to your booking please contact the support department.",
      shipmentRef: @shipment.imc_reference
    }
  end

  def booking_declined_message
    {
      title: 'Booking Declined',
      message: "Your booking has been declined! This could be due to a number of \
        reasons including cargo size/weight and goods type. For more info contact \
        us through the support channels.",
      shipmentRef: @shipment.imc_reference
    }
  end
end
