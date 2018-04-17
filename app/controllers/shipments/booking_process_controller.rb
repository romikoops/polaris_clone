class Shipments::BookingProcessController < ApplicationController
	skip_before_action :require_non_guest_authentication!,
		except: [:update_shipment, :request_shipment]

	def create_shipment
	  resp = ShippingTools.create_shipment(params[:details], current_user)
	  response_handler(resp)
	end

	def get_offers
	  resp = ShippingTools.get_offers(params, current_user)
	  response_handler(resp)
	end

	def choose_offer
	  resp = ShippingTools.choose_offer(params, current_user)
	  response_handler(resp)
	end
	
	def update_shipment
	  resp = ShippingTools.update_shipment(params, current_user)
	  response_handler(resp)
	end
	
	def request_shipment
	  resp = ShippingTools.request_shipment(params, current_user)
	  ShippingTools.tenant_notification_email(resp.user, resp)
	  ShippingTools.shipper_notification_email(resp.user, resp)
	  response_handler(shipment: resp)
	end
end