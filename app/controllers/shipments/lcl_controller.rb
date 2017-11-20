class Shipments::LclController < ApplicationController
	include ShippingTools

  before_action :require_login_and_correct_id, except: [:test_email]

  layout 'dashboard'

  def test_email
    forwarder_notification_email(current_user, Shipment.first)
  end

  def reuse_booking_data
		reuse_shipment_data(params, session, 'lcl')
  end

  def create
		resp = new_shipment(session, "lcl")
    json_response(resp, 200)
  end

  def get_offer
		get_shipment_offer(session, params, 'lcl')
    render 'new_get_offer'
  end

  # def get_offer
  #   @shipment = Shipment.find(23)
  #   @total_price = 1271
  #   @has_pre_carriage = true
  #   @has_on_carriage = true
  #   stop1 = Location.find(23)
  #   stop2 = Location.find(179)
  #   current_eta_in_search = Chronic.parse("28 September 2017")
  #   @schedules = VesselSchedule.where(from: stop1.hub_name, to: stop2.hub_name)
  #                   .where("eta > ?", current_eta_in_search)
  #                   .order(eta: :asc)
  #   @truck_seconds_pre_carriage = 500
    
  #   render 'new_get_offer'
  # end

  def finish_booking
		finish_shipment_booking(session)
  end

  def update
		update_shipment(session, params)
  end

  def get_shipper_pdf
		get_shipment_pdf(params)
  end


  private

  def require_login_and_correct_id
    unless user_signed_in?
      json_response({error: "You are not signed in"}, 500)
    end
  end
end
