# frozen_string_literal: true

class UsersController < ApplicationController
  include PricingTools
  include CurrencyTools
  skip_before_action :require_authentication!, only: :currencies
  skip_before_action :require_non_guest_authentication!, only: %i(update set_currency currencies)

  def home
    response = Rails.cache.fetch("#{current_user.shipments.cache_key}/dashboard_index", expires_in: 12.hours) do
      
      @contacts = current_user.contacts.where(alias: false).map do |contact|
        contact.as_json(
          include: { address: { include: { country: { only: :name } },
                                except: %i(created_at updated_at country_id) } },
          except: %i(created_at updated_at address_id)
        )
      end
      @aliases = current_user.contacts.where(alias: true)
      user_locs = current_user.user_addresses
      addresses = user_locs.map do |ul|
        { user: ul, address: ul.address.to_custom_hash }
      end

      resp = {
        shipments:         shipments_hash,
        contacts:          @contacts,
        num_contact_pages: (current_user.contacts.count.to_f / 6).to_f.ceil,
        aliases:           @aliases,
        addresses:         addresses
      }
    end
    response_handler(response)
  end

  def account
    @user = current_user
    @addresses = @user.addresses

    { addresses: @addresses }
  end

  def update
    @user = current_user
    updating_guest_to_regular_user = current_user.guest
    @user.update_attributes(user_params)

    if @user.valid? && !@user.guest && params[:update][:address]
      address = Address.create_from_raw_params!(address_params)
      address.geocode_from_address_fields!
      @user.addresses << address unless address.nil?
      @user.optin_status = OptinStatus.find_by(tenant: true, itsmycargo: true, cookies: @user.optin_status.cookies)
      @user.send_confirmation_instructions if updating_guest_to_regular_user
      @user.save
    end

    headers = @user.create_new_auth_token
    response_handler(user: @user.token_validation_response, headers: headers)
  end

  def currencies
    currency = current_user.try(:currency) || 'EUR'
    tenant_id = Tenant.find_by_subdomain(params[:subdomain_id]).id
    results = get_currency_array(currency, tenant_id)
    response_handler(results)
  end

  def download_gdpr
    url = DocumentService::GdprWriter.new(user_id: current_user.id).perform
    response_handler(url: url, key: 'gdpr')
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
    new_status.delete('id')
    new_status.delete('updated_at')
    new_status.delete('created_at')
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

  def shipments_hash
    current_user.tenant.quotation_tool ?
    {
      quoted:   quoted_shipments.order(booking_placed_at: :desc).limit(3)&.map(&:with_address_index_json)
    } : {
      requested: requested_shipments.order(booking_placed_at: :desc).limit(3)&.map(&:with_address_index_json)
    }
  end

  def requested_shipments
    @requested_shipments ||= current_user.shipments.requested
  end

  def quoted_shipments
    @quoted_shipments ||= current_user.shipments.quoted
  end

  def open_shipments
    @open_shipments ||= current_user.shipments.open
  end

  def rejected_shipments
    @rejected_shipments ||= current_user.shipments.rejected
  end
  
  def archived_shipments
    @archived_shipments ||= current_user.shipments.archived
  end

  def finished_shipments
    @finished_shipments ||= current_user.shipments.finished
  end

  def address_params
    params.require(:update).require(:address).permit(
      :street, :street_number, :zip_code, :city, :country
    )
  end
end
