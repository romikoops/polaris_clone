module ShippingTools
  include PricingTools
  include MongoTools

  def new_shipment(load_type)
    shipment = Shipment.create(
      shipper_id: current_user.id, 
      status: "booking_process_started", 
      load_type: load_type, 
      tenant_id: current_user.tenant_id
    )

    shipment.containers.create  if load_type.include?('fcl') && shipment.containers.empty?
    shipment.cargo_items.create if load_type.include?('lcl') && shipment.cargo_items.empty?

    route_ids_dedicated = Route.ids_dedicated(current_user)

    # Needs refactoring
    acronym_to_load_type = {
      'fcl' => 'container',
      'lcl' => 'cargo_item'
    }
    load_type = acronym_to_load_type[load_type]
    mot_scope_args = { ("only_" + load_type).to_sym => true }
    mot_scope_ids  = current_user.tenant.mot_scope(mot_scope_args).intercepting_scope_ids
    routes = get_scoped_routes(current_user.tenant_id, mot_scope_ids)

    routes.map! do |route|
      route["dedicated"] = true if route_ids_dedicated.include?(route["id"])
      route
    end

    return {
      shipment:    shipment,
      all_nexuses: Location.nexuses,
      routes:      routes
    }
  end 

  def get_shipment_offer(session, params, load_type)
    @shipment = Shipment.find(params[:shipment_id])
    offer_calculation = OfferCalculator.new(@shipment, params, load_type, current_user)

    begin
      offer_calculation.calc_offer!
    rescue
      raise ApplicationError::NoRoutes
    end

    if offer_calculation.shipment.save
      return {
        shipment:                   offer_calculation.shipment,
        total_price:                offer_calculation.total_price,
        has_pre_carriage:           offer_calculation.has_pre_carriage,
        has_on_carriage:            offer_calculation.has_on_carriage,
        schedules:                  offer_calculation.schedules,
        truck_seconds_pre_carriage: offer_calculation.truck_seconds_pre_carriage,
        originHubs:                 offer_calculation.origin_hubs,
        destinationHubs:            offer_calculation.destination_hubs
      }
    else
      raise ApplicationError::NoRoutes # TBD - Customize Errors
    end
  end

  def create_document(file, shipment, type, user) 
    Document.new_upload(file, shipment, type, user)
  end

  def update_shipment(session, params)
    @shipment = Shipment.find(params[:shipment_id])
    create_documents(params, @shipment)
    shipment_data = params[:shipment]
    consignee_data = shipment_data[:consignee]
    shipper_data = shipment_data[:shipper]
    contacts_data = shipment_data[:notifyees]
    hsCodes = shipment_data[:hsCodes].as_json
    @shipment.assign_attributes(status: "requested", total_goods_value: shipment_data[:totalGoodsValue], cargo_notes: shipment_data[:cargoNotes])

    contact_location = Location.create_and_geocode(street_number: consignee_data[:number], street: consignee_data[:street], zip_code: consignee_data[:zipCode], city: consignee_data[:city], country: consignee_data[:country])
    contact = current_user.contacts.find_or_create_by(location_id: contact_location.id, first_name: consignee_data[:firstName], last_name: consignee_data[:lastName], email: consignee_data[:email], phone: consignee_data[:phone])
    


    @consignee = @shipment.shipment_contacts.find_or_create_by(contact_id: contact.id, contact_type: 'consignee')
    @notifyees = []
    notifyee_contacts = []
    # @shipment.consignee = consignee
    unless contacts_data.nil?
      contacts_data.each do |value|

        notifyee = current_user.contacts.find_or_create_by(first_name: value[:firstName],
                                                           last_name: value[:lastName],
                                                           email: value[:email],
                                                           phone: value[:phone])
        notifyee_contacts << notifyee
        @notifyees << @shipment.shipment_contacts.find_or_create_by(contact_id: notifyee.id, contact_type: 'notifyee')
      end
    end

    if !shipment_data[:shipper][:location_id]
      new_loc = Location.create_and_geocode(street: shipment_data[:shipper][:street], street_number: shipment_data[:shipper][:number], zip_code: shipment_data[:shipper][:zipCode], city: shipment_data[:shipper][:city], country: shipment_data[:shipper][:country])
    else 
      new_loc = Location.find(shipment_data[:shipper][:location_id])
    end
    shipper_contact = current_user.contacts.find_or_create_by!(location_id: new_loc.id, first_name: shipper_data[:firstName], last_name: shipper_data[:lastName], email: shipper_data[:email], phone: shipper_data[:phone], alias: true)
    @shipper = @shipment.shipment_contacts.find_or_create_by(contact_id: shipper_contact.id, contact_type: 'shipper')
    new_user_loc = current_user.user_locations.find_or_create_by(location_id: new_loc.id)


    if new_user_loc.id == 1
      new_user_loc.update_attributes!(primary: true)
    end
    ## TODO Adjust for multiple schedules
    if shipment_data[:insurance][:bool]
      @shipment.schedule_set.each do |ss|
        key = ss.hub_route_key
        @shipment.schedules_charges[key][:insurance] = {val: shipment_data[:insurance][:val], currency: "EUR"}
        @shipment.schedules_charges[key]["total"] += shipment_data[:insurance][:val]
        @shipment.total_price = @shipment.schedules_charges[key]["total"]
      end
    end
    if @shipment.cargo_items
      @cargos = @shipment.cargo_items
      @shipment.cargo_items.map do |ci|
        if hsCodes[ci.id.to_s]
          hsCodes[ci.id.to_s].each do |hs|
            ci.hs_codes << hs["value"]
          end
          ci.save!
        end
      end
    end
    if @shipment.containers
      @containers = @shipment.containers
      @shipment.containers.map do |cn|
        hsCodes[cn.id.to_s].each do |hs|
          cn.hs_codes << hs["value"]
        end
        cn.save!
      end
    end

    @shipment.shipper_location = new_loc
    @shipment.save!
    @schedules = []
    @shipment.schedule_set.each do |ss|
      @schedules.push(Schedule.find(ss['id']))
    end
    
    @origin = @schedules.first.hub_route.starthub
    @destination =  @schedules.last.hub_route.endhub
    hubs = {startHub: {data: @origin, location: @origin.nexus}, endHub: {data: @destination, location: @destination.nexus}}

    return {
      shipment: @shipment,
      schedules: @schedules,
      hubs: hubs,
      consignee: {data:contact, location: contact_location},
      notifyees: notifyee_contacts,
      shipper:{data:shipper_contact, location: new_loc},
      cargoItems: @cargos,
      containers: @containers
    }
  end

  def finish_shipment_booking(params)
    @user_locations = []
    current_user.user_locations.each do |uloc|
      @user_locations.push({location: uloc.location, contact: current_user})
    end

    @contacts = []
    current_user.contacts.each do |c|
      @contacts.push({location: c.location, contact: c})
    end
    @shipment = Shipment.find(params[:shipment_id])
    @shipment.shipper_id = params[:shipment][:shipper_id]
    @shipment.total_price = params[:total]
    @schedules = []
    params[:schedules].each do |sched|
      schedule = Schedule.find(sched[:id])
      @shipment.schedule_set << {id: schedule.id, hub_route_key: schedule.hub_route_key}
      @schedules << schedule
    end
    case @shipment.load_type
      when 'lcl'
        @dangerous = false
        res = @shipment.cargo_items.where(dangerous_goods: true)
        if res.length > 0
          @dangerous = true
        end
      when 'fcl'
        @dangerous = false
        res = @shipment.containers.where(dangerous_goods: true)
        if res.length > 0
          @dangerous = true
        end
    end

    @shipment.save!
    @origin = @schedules.first.hub_route.starthub
    @destination =  @schedules.last.hub_route.endhub
    documents = {}
    @shipment.documents.each do |doc|
      documents[doc.doc_type] = doc
    end
    hub_route = @schedules.first.hub_route_id
    cargo_items = @shipment.cargo_items
    containers = @shipment.containers
    if containers.length > 0
      cargoKey = containers.first.size_class
    else
      cargoKey = 'lcl'
    end
    transportKey = @schedules.first.vehicle.transport_categories.find_by(name: 'any', cargo_class: cargoKey).id
    priceKey = "#{@schedules.first.hub_route_id}_#{transportKey}_#{current_user.tenant_id}_#{cargoKey}"
    customs_fee = get_item('customsFees', '_id', priceKey)

    @schedules = params[:schedules]
    hubs = {startHub: {data: @origin, location: @origin.nexus}, endHub: {data: @destination, location: @destination.nexus}}
    return {shipment: @shipment, hubs: hubs, contacts: @contacts, userLocations: @user_locations, schedules: @schedules, dangerousGoods: @dangerous, documents: documents, containers: containers, cargoItems: cargo_items, customs: customs_fee}
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
    bill_of_lading = build_and_upload_pdf(
      layout:   "pdfs/simple.pdf.html.erb",
      template: "shipments/pdfs/bill_of_lading.pdf.html.erb",
      margin:   { top: 10, bottom: 5, left: 8, right: 8 },
      shipment: shipment,
      name:     'bill_of_lading'
    )

    invoice = build_and_upload_pdf(
      layout:   "pdfs/simple.pdf.html.erb",
      template: "shipments/pdfs/invoice.pdf.html.erb",
      margin:   { top: 10, bottom: 5, left: 15, right: 15 },
      shipment: shipment,
      name:     'invoice'
    )

    files = {
      bill_of_lading[:name] => bill_of_lading[:url],
      invoice[:name]        => invoice[:url]
    }

    ShipmentMailer.shipper_confirmation(
      user, 
      shipment, 
      files
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
    
    doc = Document.new_upload_backend(doc_pdf, args[:shipment], 'confirmation', current_user)
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
