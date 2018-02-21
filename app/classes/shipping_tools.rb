module ShippingTools
  include PricingTools
  include MongoTools
  include NotificationTools

  def new_shipment(load_type)
    tenant = current_user.tenant

    shipment = Shipment.create(
      shipper_id: current_user.id, 
      status: "booking_process_started", 
      load_type: load_type, 
      tenant_id: tenant.id
    )

    shipment.send("#{load_type}s").create if shipment.send("#{load_type}s").empty?

    itinerary_ids_dedicated = Itinerary.ids_dedicated(current_user)

    mot_scope_args = { ("only_" + load_type).to_sym => true }
    mot_scope_ids  = current_user.tenant.mot_scope(mot_scope_args).intercepting_scope_ids
    itineraries = Itinerary.mot_scoped(current_user.tenant_id, mot_scope_ids)
    byebug
    origins = []
    destinations = []
    itineraries.map! do |itinerary|
      origins << { 
        value: Location.find(itinerary["origin_nexus_id"]), 
        label: itinerary["origin_nexus"] 
      }
      destinations << { 
        value: Location.find(itinerary["destination_nexus_id"]), 
        label: itinerary["destination_nexus"] 
      }

      itinerary["dedicated"] = true if itinerary_ids_dedicated.include?(itinerary["id"])
      itinerary
    end
    return {
      shipment:       shipment,
      all_nexuses:    { origins: origins.uniq, destinations: destinations.uniq },
      itineraries:    itineraries,
      cargoItemTypes: tenant.cargo_item_types
    }
  end 

  def get_shipment_offer(session, params, load_type)
    shipment = Shipment.find(params[:shipment_id])
    offer_calculation = OfferCalculator.new(shipment, params, current_user)

    offer_calculation.calc_offer!

    if offer_calculation.shipment.save
      cargo_units = offer_calculation.shipment.load_type == 'cargo_item' ? offer_calculation.shipment.cargo_items : offer_calculation.shipment.containers
      return {
        shipment:                   offer_calculation.shipment,
        total_price:                offer_calculation.total_price,
        has_pre_carriage:           offer_calculation.has_pre_carriage,
        has_on_carriage:            offer_calculation.has_on_carriage,
        schedules:                  offer_calculation.schedules,
        truck_seconds_pre_carriage: offer_calculation.truck_seconds_pre_carriage,
        originHubs:                 offer_calculation.origin_hubs,
        destinationHubs:            offer_calculation.destination_hubs,
        cargoUnits:                 cargo_units
      }
    else
      raise ApplicationError::NoRoutes # TBD - Customize Errors
    end

  end

  def create_document(file, shipment, type, user) 
    Document.new_upload(file, shipment, type, user)
  end

  def update_shipment(session, params)
    tenant = current_user.tenant
    shipment = Shipment.find(params[:shipment_id])
    shipment_data = params[:shipment]

    hsCodes = shipment_data[:hsCodes].as_json
    hsTexts = shipment_data[:hsTexts].as_json
    shipment.assign_attributes(
      
      total_goods_value: shipment_data[:totalGoodsValue], 
      cargo_notes: shipment_data[:cargoNotes]
    )

    # Shipper
    resource = shipment_data.require(:shipper)
    contact_location = Location.create_and_geocode(contact_location_params(resource))
    contact = current_user.contacts.find_or_create_by(
      contact_params(resource, contact_location.id).merge({ alias: true })
    )
    shipment.shipment_contacts.find_or_create_by(contact_id: contact.id, contact_type: 'shipper')
    user_location = current_user.user_locations.find_or_create_by(location_id: contact_location.id)
    user_location.update_attributes!(primary: true) if user_location.id == 1
    shipment.shipper_location = contact_location
    shipper = { data: contact, location: contact_location }

    # Consignee
    resource = shipment_data.require(:consignee)
    contact_location = Location.create_and_geocode(contact_location_params(resource))
    contact = current_user.contacts.find_or_create_by(contact_params(resource, contact_location.id))
    shipment.shipment_contacts.find_or_create_by!(contact_id: contact.id, contact_type: 'consignee')
    consignee = { data: contact, location: contact_location }

    # Notifyees
    notifyees = shipment_data[:notifyees].try(:map) do |resource|
      contact = current_user.contacts.find_or_create_by!(contact_params(resource))
      shipment.shipment_contacts.find_or_create_by!(contact_id: contact.id, contact_type: 'notifyee')
      contact
    end || []

    # TBD - Adjust for itinerary logic
    if shipment_data[:insurance][:bool]
      shipment.schedule_set.each do |ss|
        key = ss["hub_route_key"]
        shipment.schedules_charges[key][:insurance] = {val: shipment_data[:insurance][:val], currency: "EUR"}
        shipment.schedules_charges[key]["total"] += shipment_data[:insurance][:val]
        shipment.total_price = shipment.schedules_charges[key]["total"]
      end
    end

    shipment.itinerary = Itinerary.find(shipment.schedule_set.first["itinerary_id"])

    if shipment.cargo_items
      @cargo_items = shipment.cargo_items.map do |cargo_item|
        hs_code_hashes = hsCodes[cargo_item.cargo_group_id.to_s]
        
        if hs_code_hashes
          cargo_item.hs_codes = hs_code_hashes.map { |hs_code_hash| hs_code_hash["value"] }
          cargo_item.save!
        end
        hs_text = hsTexts[cargo_item.cargo_group_id.to_s]
        
        if hs_text
          cargo_item.customs_text = hs_text
          cargo_item.save!
        end
        cargo_item.attributes.merge({ chargeable_weight: cargo_item.chargeable_weight(shipment.itinerary.mode_of_transport).to_f })
      end
    end
    if shipment.containers
      @containers = shipment.containers
      shipment.containers.map do |cn|
        if hsCodes[cn.cargo_group_id.to_s]
          hsCodes[cn.cargo_group_id.to_s].each do |hs|
            cn.hs_codes << hs["value"]
          end
          cn.save!
        end
        hs_text = hsTexts[cn.cargo_group_id.to_s]
        
        if hs_text
          cn.customs_text = hs_text
          cn.save!
        end
      end
    end
    
    @schedules = []
    shipment.schedule_set.each do |ss|
      @schedules.push(ss)
    end
    shipment.planned_etd = @schedules.first["etd"]
    shipment.planned_eta = @schedules.last["eta"]
    shipment.save!
    @origin = Layover.find(@schedules.first["origin_layover_id"]).stop.hub
    @destination =  Layover.find(@schedules.first["destination_layover_id"]).stop.hub
    hubs = {startHub: {data: @origin, location: @origin.nexus}, endHub: {data: @destination, location: @destination.nexus}}

    

    return {
      shipment:   shipment,
      schedules:  @schedules,
      hubs:       hubs,
      consignee:  consignee,
      notifyees:  notifyees,
      shipper:    shipper,
      cargoItems: @cargo_items,
      containers: @containers
    }
  end

  def confirm_booking(params)
    shipment = Shipment.find(params[:shipment_id])
    shipment.status = "requested"
    shipment.save!
    message = {
      title: 'Booking Received',
      message: "
        Thank you for making your booking through #{current_user.tenant.name}. 
        You will be notified upon confirmation of the order.
      ", 
      shipmentRef: shipment.imc_reference
    }
    add_message_to_convo(current_user, message, true)
    return shipment
  end

  def contact_location_params(resource)
    resource.require(:location)
      .permit(:street, :streetNumber, :zipCode, :city, :country)
      .to_h.deep_transform_keys { |key| key.underscore }
  end

  def contact_params(resource, location_id = nil)
    resource.require(:contact)
      .permit(:companyName, :firstName, :lastName, :email, :phone)
      .to_h.deep_transform_keys { |key| key.underscore }
      .merge({ location_id: location_id })
  end

  def finish_shipment_booking(params)
    @user_locations = current_user.user_locations.map do |uloc|
      { 
        location: uloc.location.attributes, 
        contact: current_user.attributes
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    @contacts = current_user.contacts.map do |contact|
      { 
        location: contact.location.try(:attributes) || {},
        contact: contact.attributes
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end
    shipment = Shipment.find(params[:shipment_id])
    shipment.shipper_id = params[:shipment][:shipper_id]
    shipment.total_price = params[:total]
    @schedules = params[:schedules].as_json
    # byebug
    params[:schedules].each do |sched|
      shipment.schedule_set << sched
    end
    case shipment.load_type
      when 'lcl'
        @dangerous = false
        res = shipment.cargo_items.where(dangerous_goods: true)
        if res.length > 0
          @dangerous = true
        end
      when 'fcl'
        @dangerous = false
        res = shipment.containers.where(dangerous_goods: true)
        if res.length > 0
          @dangerous = true
        end
    end
    shipment.save!
    @origin = Layover.find(@schedules.first["origin_layover_id"]).stop.hub
    @destination =  Layover.find(@schedules.first["destination_layover_id"]).stop.hub
    documents = {}
    shipment.documents.each do |doc|
      documents[doc.doc_type] = doc
    end
    hub_route = @schedules.first["hub_route_id"]
    cargo_items = shipment.cargo_items
    containers = shipment.containers
    if containers.length > 0
      cargoKey = containers.first.size_class
    else
      cargoKey = 'lcl'
    end
    transportKey = Trip.find(@schedules.first["trip_id"]).vehicle.transport_categories.find_by(name: 'any', cargo_class: cargoKey).id
    priceKey = "#{@schedules.first["itinerary_id"]}_#{transportKey}_#{current_user.tenant_id}_#{cargoKey}"
    customs_fee = get_item('customsFees', '_id', priceKey)
    # @schedules = params[:schedules]
    hubs = {startHub: {data: @origin, location: @origin.nexus}, endHub: {data: @destination, location: @destination.nexus}}
    return {shipment: shipment, hubs: hubs, contacts: @contacts, userLocations: @user_locations, schedules: @schedules, dangerousGoods: @dangerous, documents: documents, containers: containers, cargoItems: cargo_items, customs: customs_fee, locations: {origin: shipment.origin, destination: shipment.destination}}
  end

  def get_shipment_pdf(params)
    shipment = Shipment.find_by_id(params[:shipment_id])
    pdf_string = render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_shipper.pdf', locals: { shipment: shipment })
    shipper_pdf = WickedPdf.new.pdf_from_string(pdf_string, :margin => {:top=> 10, :bottom => 5, :left=> 20, :right => 20})
    send_data shipper_pdf, filename: "Booking_" + shipment.imc_reference + ".pdf"
  end

  def tenant_notification_email(user, shipment)
    ShipmentMailer.tenant_notification(user, shipment).deliver_later
  end

  def shipper_notification_email(user, shipment)
    ShipmentMailer.shipper_notification(user, shipment).deliver_later
  end

  def shipper_confirmation_email(user, shipment)
    ShipmentMailer.shipper_confirmation(
      user, 
      shipment
    ).deliver_later
  end

  def build_and_upload_pdf(args)
    doc_erb = ErbTemplate.new(
      layout:   args[:layout],
      template: args[:template],
      locals:   { shipment: args[:shipment] }
    )

    doc_string = WickedPdf.new.pdf_from_string(
      doc_erb.render,
      margin: args[:margin]
    )
        
    doc_name = "#{args[:name]}_#{args[:shipment].imc_reference}.pdf"
    
    File.open("tmp/" + doc_name, 'wb') { |file| file.write(doc_string) }
    doc_pdf = File.open("tmp/" + doc_name)
    
    doc = Document.new_upload_backend(doc_pdf, args[:shipment], args[:name], current_user)
    doc_url = doc.get_signed_url
    
    { name: doc_name, url: doc_url }
  end


  def send_booking_emails(shipment)
    shipper_pdf = WickedPdf.new.pdf_from_string(render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_shipper.pdf', locals: { shipment: shipment }), :margin => {:top=> 10, :bottom => 5, :left=> 20, :right => 20})
    trucker_pdf = WickedPdf.new.pdf_from_string(render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_trucker.pdf', locals: { shipment: shipment }), :margin => {:top=> 10, :bottom => 5, :left=> 20, :right => 20})
    consolidator_pdf = WickedPdf.new.pdf_from_string(render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_consolidator.pdf', locals: { shipment: shipment }), :margin => {:top=> 10, :bottom => 5, :left=> 20, :right => 20})
    receiver_pdf = WickedPdf.new.pdf_from_string(render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_receiver.pdf', locals: { shipment: shipment }), :margin => {:top=> 10, :bottom => 5, :left=> 20, :right => 20})
    ShipmentMailer.summary_mail_shipper(shipment, "Booking_" + shipment.imc_reference + ".pdf", shipper_pdf).deliver_now
    ShipmentMailer.summary_mail_trucker(shipment, "Booking_" + shipment.imc_reference + ".pdf", trucker_pdf).deliver_now
    ShipmentMailer.summary_mail_consolidator(shipment, "Booking_" + shipment.imc_reference + ".pdf", consolidator_pdf).deliver_now
    ShipmentMailer.summary_mail_receiver(shipment, "Booking_" + shipment.imc_reference + ".pdf", receiver_pdf).deliver_now

    # TBD - Set up flash message
  end

  def get_hs_code_hash(codes)
    resp = get_items_by_key_values(false, 'hsCodes', '_id', codes)
    results = {}
    
    resp.each do |hs|
      results[hs["_id"]] = hs 
    end
    results
  end
end
