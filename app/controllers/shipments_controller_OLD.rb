class ShipmentsController < ApplicationController
  before_action :require_login_and_correct_id, except: [:test_email]

  layout 'dashboard'

  def test_email
    forwarder_notification_email(current_user, Shipment.first)
  end

  def index
    @shipper = current_user

    @requested_shipments = @shipper.shipments.where(status: "requested")
    @open_shipments = @shipper.shipments.where(status: ["accepted", "in_progress"])
    @finished_shipments = @shipper.shipments.where(status: ["declined", "finished"])
  end

  def reuse_booking_data
    user = User.find(params[:user_id])
    shipment = user.shipments.find(params[:shipment_id])
    session[:shipment_uuid] = shipment.uuid
    session[:reuse_shipment] = "true"

    redirect_to(new_user_shipment_path)    
  end

  def new
    if session[:shipment_uuid].nil? || session[:shipment_uuid].empty?
      @shipment = Shipment.create(shipper_id: current_user.id, status: "booking_process_started")
      @shipment.containers.create
      session[:shipment_uuid] = @shipment.uuid
    else
      shipment = Shipment.find_by_uuid(session[:shipment_uuid])
      if shipment.booked?
        if session[:reuse_shipment].to_bool
          @shipment = Shipment.create(shipper_id: current_user.id)
        else
          @shipment = shipment.dup
        end
        @shipment.containers.create
        session[:shipment_uuid] = @shipment.uuid
      else
        @shipment = shipment
      end
    end

    @has_pre_carriage = @shipment.has_pre_carriage || true
    @has_on_carriage = @shipment.has_on_carriage || true
    @all_hubs = Location.all_hubs_prepared

    @tare_weights = CONTAINER_WEIGHTS
    @container_descriptions = CONTAINER_DESCRIPTIONS.invert

    render 'new_first_details'
  end

  def get_offer
    @shipment = Shipment.find_by_uuid(session[:shipment_uuid])

    offer_calculation = OfferCalculator.new(@shipment, params)
    ###
    # offer_calculation.calc_offer!
    ###
    begin
      offer_calculation.calc_offer!
    rescue
      @no_transport_available = true
      render 'new_get_offer' and return
    end
    offer_calculation.calc_alternative_schedules!(up_to = 25)
    @shipment = offer_calculation.shipment
    @shipment.save!
    @total_price = @shipment.total_price
    @has_pre_carriage = @shipment.has_pre_carriage
    @has_on_carriage = @shipment.has_on_carriage
    @schedule_sets = offer_calculation.schedule_set_arr
    
    render 'new_get_offer'
  end

  def price_details
    @shipment = Shipment.find_by_uuid(session[:shipment_uuid])
    @trade_direction = @shipment.route.trade_direction
    @has_pre_carriage = @shipment.has_pre_carriage
    @has_on_carriage = @shipment.has_on_carriage
    @total_price = @shipment.total_price
    @export_charges = ServiceCharge.for_export if @trade_direction == "export"
    @import_charges = ServiceCharge.for_import if @trade_direction == "import"
    @total_service_charges = []
    @shipment.containers.each do |container|
      charge = ServiceCharge.find_by(container_size_class: container.size_class, trade_direction: @trade_direction)
      service_charges_price = charge.total_price(@trade_direction, @has_pre_carriage, @has_on_carriage)
      @total_service_charges << service_charges_price
    end
    @pre_carriage_price_per_container = TruckingPricing.first.price(@shipment.pre_carriage_distance_km, 1)
    @on_carriage_price_per_container = TruckingPricing.first.price(@shipment.on_carriage_distance_km, 1)

    render 'new_price_details'
  end

  def finish_booking
    @shipment = Shipment.find_by_uuid(session[:shipment_uuid])

    @total_price = @shipment.total_price

    render 'new_finish_booking'
  end

  def update
    @shipment = Shipment.find_by_uuid(session[:shipment_uuid])

    shipment_data = params[:shipment]
    consignee_data = shipment_data[:consignee]
    notifyees_data = shipment_data[:notifyees_attributes]

    @shipment.assign_attributes(status: "requested", hs_code: shipment_data[:hs_code], total_goods_value: shipment_data[:total_goods_value], cargo_notes: shipment_data[:cargo_notes])

    consignee = Consignee.new(first_name: consignee_data[:first_name], last_name: consignee_data[:last_name])
    consignee.location = Location.new(street: consignee_data[:street], zip_code: consignee_data[:zip_code], city: consignee_data[:city], country: consignee_data[:country])
    
    @shipment.consignee = consignee
    unless notifyees_data.nil?
      notifyees_data.values.each do |value|
        notifyee = Notifyee.new(first_name: value[:first_name],
          last_name: value[:last_name],
          email: value[:email],
          phone: value[:phone])
        @shipment.notifyees << notifyee
      end
    end

    @shipment.save!
    session.delete(:shipment_uuid)

    render 'new_booking_confirmation'
  end

  # def create
  #   shipment = Shipment.find_by_uuid(session[:shipment_uuid])

  #   shipment.shipper = current_user #!!!!!!!!!!!!!!!!!!!!!!!
  #   shipment.shipper_legal_location = shipment.shipper.locations.first #!!!!!!!!!!!!!!!!!!!!!!!
  #   shipment.receiver = Receiver.new_from_params(params[:shipment][:receiver])
  #   cargo_description = params[:shipment][:cargo_description]
  #   shipment.cargo_description.update_attributes(goods_type: cargo_description[:goods_type], packaging: cargo_description[:packaging], stackable: cargo_description[:stackable], europallet: cargo_description[:europallet], notes: cargo_description[:notes])
  #   shipment.estimated_value = params[:shipment][:estimated_value]
  #   # shipment.insurance_wanted

  #   shipment.save!
  #   ################ VALIDATIONS!

  #   # send_booking_emails(shipment)

  #   session.delete(:shipment_uuid)
    
  #   shipment.update_attribute(:booked, true)
  #   redirect_to shipper_shipment_complete_path(shipment.shipper.id, shipment.id)
  # end

  def get_shipper_pdf
    shipment = Shipment.find_by_id(params[:shipment_id])
    pdf_string = render_to_string(layout: 'pdfs/booking.pdf', template: 'shipments/pdfs/booking_shipper.pdf', locals: { shipment: shipment })
    shipper_pdf = WickedPdf.new.pdf_from_string(pdf_string, :margin => {:top=> 10, :bottom => 5, :left=> 20, :right => 20})
    send_data shipper_pdf, filename: "Booking_" + shipment.imc_reference + ".pdf"
  end

  private

  def forwarder_notification_email(user, shipment)
    ShipmentMailer.forwarder_notification(user, shipment).deliver_now
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

  def require_login_and_correct_id
    unless user_signed_in? && current_user.id.to_s == params[:user_id]
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end