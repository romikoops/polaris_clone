class Shipments::Open::LclController < ApplicationController
	include ShippingTools
  include Response
  before_action :require_login_and_correct_id, except: [:test_email]

  def reuse_booking_data

		reuse_shipment_data(params, session, 'openlcl')   
  end

  def create
		resp = new_shipment(session, 'openlcl')
    json_response(resp, 200)
  end

  def get_offer
		get_shipment_offer(session, params, 'openlcl')
    render 'new_get_offer'
  end 

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
    unless user_signed_in? && current_user.id.to_s == params[:user_id]
       json_response({error: "You are not signed in"}, 500)
    end
  end
end
