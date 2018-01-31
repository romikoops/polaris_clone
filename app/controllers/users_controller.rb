class UsersController < ApplicationController
  include PricingTools
  include CurrencyTools
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def home
    @shipper = current_user

    @requested_shipments = @shipper.shipments.where(status: "requested")
    @open_shipments = @shipper.shipments.where(status: ["accepted", "in_progress", "confirmed"])
    @finished_shipments = @shipper.shipments.where(status: ["declined", "finished"])
    @pricings = get_user_pricings(@shipper.id)
    @contacts = @shipper.contacts.where(alias: false)
    @aliases = @shipper.contacts.where(alias: true)
    @locations = []
    user_locs = @shipper.user_locations
    user_locs.each do |ul|
      @locations.push({user: ul, location: ul.location})
    end
    route_ids_dedicated = Route.ids_dedicated(current_user)
    mot_scope_args = {}
    mot_scope_ids  = current_user.tenant.mot_scope(mot_scope_args).intercepting_scope_ids
    routes = Route.mot_scoped(current_user.tenant_id, mot_scope_ids)
    routes.map! do |route|
      route["dedicated"] = true if route_ids_dedicated.include?(route["id"])
      route
    end
    resp = {
      shipments:{
        requested: @requested_shipments,
        open: @open_shipments,
        finished: @finished_shipments
      },
      pricings: @pricings,
      contacts: @contacts,
      aliases: @aliases,
      locations: @locations,
      routes: routes
    }
    response_handler(resp)
  end

  def account
    @user = current_user
    @locations = @user.locations

    return {locations: @locations}
  end

  def update
    @user = current_user
    @user.update_attributes(update_params)
    headers = @user.create_new_auth_token
    response_handler({user: @user, headers: headers})
  end
  def currencies
    currency = current_user ? current_user.currency : "EUR"
    results = get_currency_array(current_user.currency)
    response_handler(results)
  end
  def set_currency
    current_user.currency = params[:currency]
    current_user.save!
    rates = get_rates(params[:currency])
    response_handler({user: current_user, rates: rates})
  end
  
  def hubs
    @hubs = Hub.prepped(current_user)
    
    response_handler(@hubs)
  end

  private

  def update_params
    params.require(:update).permit(
      :first_name, :last_name, :email, :phone, :company_name, :password, :guest, :tenant_id
    )
  end
end
