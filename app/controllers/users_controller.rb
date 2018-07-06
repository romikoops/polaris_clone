# frozen_string_literal: true

class UsersController < ApplicationController
  include PricingTools
  include CurrencyTools
  skip_before_action :require_authentication!, only: :currencies
  skip_before_action :require_non_guest_authentication!, only: %i[update set_currency currencies]

  def home
    @shipper = current_user
    options = {methods: [:selected_offer, :mode_of_transport], include:[ { destination_nexus: {}},{ origin_nexus: {}}, { destination_hub: {}}, { origin_hub: {}} ]}
    requested_shipments = @shipper.shipments.where(
      status:    %w[requested requested_by_unconfirmed_account],
      tenant_id: current_user.tenant_id
    ).order(booking_placed_at: :desc)
    open_shipments = @shipper.shipments.where(
      status:    %w[in_progress confirmed],
      tenant_id: current_user.tenant_id
    ).order(booking_placed_at: :desc)
    finished_shipments = @shipper.shipments.where(status: "finished", tenant_id: current_user.tenant_id).order(booking_placed_at: :desc)
    @requested_shipments = requested_shipments.map{|shipment| shipment.with_address_options_json}
    @open_shipments = open_shipments.map{|shipment| shipment.with_address_options_json}
    @finished_shipments = finished_shipments.map{|shipment| shipment.with_address_options_json}

    @pricings = get_user_pricings(@shipper.id)
    @contacts = @shipper.contacts.where(alias: false)
    @aliases = @shipper.contacts.where(alias: true)

    user_locs = @shipper.user_locations
    locations = user_locs.map do |ul|
      { user: ul, location: ul.location }
    end

    resp = {
      shipments: {
        requested: @requested_shipments,
        open:      @open_shipments,
        finished:  @finished_shipments
      },
      pricings:  @pricings,
      contacts:  @contacts,
      aliases:   @aliases,
      locations: locations
    }
    response_handler(resp)
  end

  def account
    @user = current_user
    @locations = @user.locations

    { locations: @locations }
  end

  def update
    @user = current_user
    updating_guest_to_regular_user = current_user.guest
    @user.update_attributes(user_params)

    if @user.valid? && !@user.guest && params[:update][:location]
      location = Location.create_from_raw_params!(location_params)
      location.geocode_from_address_fields!
      @user.locations << location unless location.nil?
      @user.optin_status = OptinStatus.find_by(tenant: true, itsmycargo: true, cookies: @user.optin_status.cookies)
      @user.send_confirmation_instructions if updating_guest_to_regular_user
      @user.save
    end

    headers = @user.create_new_auth_token
    response_handler(user: @user.token_validation_response, headers: headers)
  end

  def currencies
    currency = current_user.try(:currency) || "EUR"
    tenant_id = current_user ? current_user.tenant_id : nil
    results = get_currency_array(currency, tenant_id)
    response_handler(results)
  end

  def download_gdpr
    url = DocumentService::GdprWriter.new(user_id: current_user.id).perform
    response_handler(url: url, key: "gdpr")
  end

  def set_currency
    current_user.currency = params[:currency]
    current_user.save!
    rates = get_rates(params[:currency], current_user.tenant_id)
    response_handler(user: current_user.token_validation_response, rates: rates)
  end

  def hubs
    @hubs = Hub.prepped(current_user)

    response_handler(@hubs)
  end

  def opt_out
    new_status = current_user.optin_status.as_json
    new_status[params[:target]] = !new_status[params[:target]]
    new_status.delete("id")
    new_status.delete("updated_at")
    new_status.delete("created_at")
    optin_status = OptinStatus.find_by(new_status)
    current_user.optin_status = optin_status
    current_user.save!
    response_handler(user: current_user.token_validation_response)
  end

  private

  def user_params
    return_params = params.require(:update).permit(
      :guest, :tenant_id, :email, :password, :confirm_password, :password_confirmation,
      :company_name, :vat_number, :VAT_number, :first_name, :last_name, :phone, :cookies
    ).to_h

    unless return_params[:confirm_password].nil?
      return_params[:password_confirmation] = return_params.delete(:confirm_password)
    end

    return_params[:vat_number] = return_params.delete(:VAT_number) unless return_params[:VAT_number].nil?

    unless return_params[:cookies].nil?
      return_params.delete(:cookies)
      return_params[:optin_status_id] = OptinStatus.find_by(tenant: !params[:guest], itsmycargo: !params[:guest], cookies: true).id
    end

    return_params
  end

  def location_params
    params.require(:update).require(:location).permit(
      :street, :street_number, :zip_code, :city, :country
    )
  end
end
