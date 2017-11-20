module ShippingTools
  def new_shipment(session, load_type)

    if session[:shipment_uuid].nil? || session[:shipment_uuid].empty?
      @shipment = Shipment.create(shipper_id: current_user.id, status: "booking_process_started", load_type: load_type)
      session[:shipment_uuid] = @shipment.uuid
    else
      shipment = Shipment.find_by_uuid(session[:shipment_uuid])
      if shipment.booked?
        if session[:reuse_shipment].to_bool
          @shipment = Shipment.create(shipper_id: current_user.id, load_type: load_type)
        else
          @shipment = shipment.dup
        end
        session[:shipment_uuid] = @shipment.uuid
      else
        @shipment = shipment
      end
      if @shipment.cargo_items.empty?
        @shipment.cargo_items.create
      end
    end

    case load_type
    when 'fcl'
      @tare_weights = CONTAINER_WEIGHTS
      @container_descriptions = CONTAINER_DESCRIPTIONS.invert
      if @shipment.containers.empty?
        @shipment.containers.create
      end
    when 'lcl'
      if @shipment.cargo_items.empty?
        @shipment.cargo_items.create
      end
    when 'openlcl'
      if @shipment.cargo_items.empty?
        @shipment.cargo_items.create
      end
    end

    @has_pre_carriage = @shipment.has_pre_carriage || true
    @has_on_carriage = @shipment.has_on_carriage || true

    if load_type.starts_with?('open')
      @all_nexuses = Location.nexuses_prepared
    else
      @all_nexuses = Location.nexuses_prepared_client(current_user)
    end

    resp = {
        data: @shipment,
        all_nexuses: @all_nexuses
    }
    return resp
  end

  def reuse_booking_data(params, session, load_type)
    user = User.find(params[:user_id])
    shipment = user.shipments.find(params[:lcl_id])
    session[:shipment_uuid] = shipment.uuid
    session[:reuse_shipment] = "true"

    case load_type
    when 'fcl'
      redirect_to(new_user_shipments_fcl_path)
    when 'lcl'
      redirect_to(new_user_shipments_lcl_path)
    when 'openlcl'
      redirect_to(new_user_shipments_open_lcl_path)
    end
  end

  def get_shipment_offer(session, params, load_type)
    @shipment = Shipment.find_by_uuid(session[:shipment_uuid])
    case load_type
    when 'fcl'
      offer_calculation = OfferCalculator.new(@shipment, params, 'fcl')
    when 'lcl'
      offer_calculation = OfferCalculator.new(@shipment, params, 'lcl')
    when 'openlcl'
      offer_calculation = OfferCalculator.new(@shipment, params, 'openlcl')
    end
    begin
      offer_calculation.calc_offer!
    rescue
      @no_transport_available = true
      # render 'new_get_offer' and return
    end

    @shipment = offer_calculation.shipment
    @shipment.save!
    @total_price = @shipment.total_price
    @has_pre_carriage = @shipment.has_pre_carriage
    @has_on_carriage = @shipment.has_on_carriage
    @schedules = offer_calculation.schedules
    @truck_seconds_pre_carriage = offer_calculation.truck_seconds_pre_carriage
  end

  def create_documents(form, shipment)
    if  form['packing_sheet']
      Document.new_upload(form['packing_sheet'], shipment, 'packing_sheet')
    end
    if  form['dangerous_goods_form']
      Document.new_upload(form['dangerous_goods_form'], shipment, 'dangerous_goods_form')
    end
    if  form['customs_dec']
      Document.new_upload(form['customs_dec'], shipment, 'customs_dec')
    end
    if  form['customs_value_dec']
      Document.new_upload(form['customs_value_dec'], shipment, 'customs_value_dec')
    end
    if  form['outside_eu']
      Document.new_upload(form['outside_eu'], shipment, 'outside_eu')
    end

  end

  def update_shipment(session, params)
    @shipment = Shipment.find_by_uuid(session[:shipment_uuid])
    create_documents(params, @shipment)
    shipment_data = params[:shipment]
    consignee_data = shipment_data[:consignee]
    contacts_data = shipment_data[:contacts_attributes]

    @shipment.assign_attributes(status: "requested", hs_code: shipment_data[:hs_code], total_goods_value: shipment_data[:total_goods_value], cargo_notes: shipment_data[:cargo_notes])

    contact_location = Location.create_and_geocode(street_address: consignee_data[:street_address], zip_code: consignee_data[:zip_code], city: consignee_data[:city], country: consignee_data[:country])
    contact = current_user.contacts.find_or_create_by(location_id: contact_location.id, first_name: consignee_data[:first_name], last_name: consignee_data[:last_name], email: consignee_data[:email], phone: consignee_data[:phone])

    
    @consignee = @shipment.shipment_contacts.create(contact_id: contact.id, contact_type: 'consignee')
    @notifyees = []
    # @shipment.consignee = consignee
    unless contacts_data.nil?
      contacts_data.values.each do |value|

        notifyee = current_user.contacts.find_or_create_by(first_name: value[:first_name],
                                                           last_name: value[:last_name],
                                                           email: value[:email],
                                                           phone: value[:phone])
        # @shipment.notifyees << notifyee
        @notifyees << @shipment.shipment_contacts.create(contact_id: notifyee.id, contact_type: 'notifyee')
      end
    end

    # user = User.new(first_name: shipment_data[:shipper][:first_name], last_name: shipment_data[:shipper][:last_name], email: shipment_data[:shipper][:email], phone: shipment_data[:shipper][:phone], company_name: current_user.company_name)
    new_loc = Location.create_and_geocode(street_address: shipment_data[:shipper][:street_address], zip_code: shipment_data[:shipper][:zip_code], city: shipment_data[:shipper][:city], country: shipment_data[:shipper][:country])
    new_user_loc = current_user.user_locations.find_or_create_by(location_id: new_loc.id)

    if new_user_loc.id == 1
      new_user_loc.update_attributes!(primary: true)
    end

    @shipment.shipper_location = new_loc
    @shipment.save!
    
    #    forwarder_notification_email(user, @shipment)
    #    booking_confirmation_email(consignee, @shipment)

    # session.delete(:shipment_uuid)

    render 'new_booking_confirmation'
  end

  def finish_shipment_booking(session)
    @shipment = Shipment.find_by_uuid(session[:shipment_uuid])
    @total_price = @shipment.total_price

    render 'new_finish_booking'
  end

  def get_shipment_pdf(params)
    shipment = Shipment.find_by_id(params[:shipment_id])
    pdf_string = render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_shipper.pdf', locals: { shipment: shipment })
    shipper_pdf = WickedPdf.new.pdf_from_string(pdf_string, :margin => {:top=> 10, :bottom => 5, :left=> 20, :right => 20})
    send_data shipper_pdf, filename: "Booking_" + shipment.imc_reference + ".pdf"
  end

  def forwarder_notification_email(user, shipment)
    ShipmentMailer.forwarder_notification(user, shipment).deliver_now
  end

  def booking_confirmation_email(user, shipment)
    ShipmentMailer.booking_confirmation(user, shipment).deliver_now
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
    flash[:message] = "Booking summaries got sent out via email."
  end
end
