class UsersController < ApplicationController
  include PricingTools
  include CurrencyTools
  include DocumentTools
  # skip_before_action :require_authentication! # TODO: why skip?
  skip_before_action :require_non_guest_authentication!, only: [:update, :set_currency]

  def home
    @shipper = current_user

    @requested_shipments = @shipper.shipments.where(status: %w(requested requested_by_unconfirmed_account))
    @open_shipments = @shipper.shipments.where(status: %w(confirmed in_progress))
    @finished_shipments = @shipper.shipments.where(status: 'finished')

    @pricings = get_user_pricings(@shipper.id)
    @contacts = @shipper.contacts.where(alias: false)
    @aliases = @shipper.contacts.where(alias: true)

    user_locs = @shipper.user_locations
    locations = user_locs.map do |ul|
      {user: ul, location: ul.location}
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
      locations: locations,
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
    updating_guest_to_regular_user = current_user.guest
    @user.update_attributes(user_params)

    if @user.valid? && !@user.guest && params[:update][:location]
      location = Location.create_from_raw_params(location_params)
      location.geocode_from_address_fields!
      @user.locations << location unless location.nil?
      
      @user.send_confirmation_instructions if updating_guest_to_regular_user
      @user.save
    end

    headers = @user.create_new_auth_token
    response_handler({ user: @user, headers: headers })
  end

  def currencies
    currency = current_user ? current_user.currency : "EUR"
    results = get_currency_array(currency)
    response_handler(results)
  end
  def download_gdpr
    url = gdpr_download(current_user.id)
    response_handler({url: url, key: 'gdpr'})
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
  def opt_out
    current_user.optin_status[params[:target]] = !current_user.optin_status[params[:target]]
    current_user.save!
    response_handler(user: current_user)
  end

  private

  def user_params
    return_params = params.require(:update).permit(
      :guest, :tenant_id, :email, :password, :confirm_password, :password_confirmation,
      :company_name, :vat_number, :VAT_number, :first_name, :last_name, :phone
    ).to_h

    unless return_params[:confirm_password].nil?
      return_params[:password_confirmation] = return_params.delete(:confirm_password)
    end

    unless return_params[:VAT_number].nil?
      return_params[:vat_number] = return_params.delete(:VAT_number)
    end

    return_params
  end

  def location_params
    params.require(:update).require(:location).permit(
      :street, :street_number, :zip_code, :city, :country
    )
  end
end
