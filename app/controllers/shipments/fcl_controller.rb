class Shipments::FclController < ApplicationController
	include ShippingTools

  before_action :require_login_and_correct_id, except: [:test_email]

  layout 'dashboard'

  def reuse_booking_data
		reuse_shipment_data(params, session, 'fcl')
  end

  def create
		resp = new_shipment(session, "fcl")
    json_response(resp, 200)
  end

  def get_offer
		get_shipment_offer(session, params, 'fcl')
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
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
