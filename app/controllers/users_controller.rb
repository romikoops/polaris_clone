# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_authentication!, only: :currencies
  skip_before_action :require_non_guest_authentication!, only: %i[update set_currency currencies]

  def home
    current_shipments = current_user.shipments.where(sandbox: @sandbox)
    response = Rails.cache.fetch("#{current_shipments.cache_key}/dashboard_index", expires_in: 12.hours) do
      @contacts = current_user.contacts.where(sandbox: @sandbox).limit(6).map do |contact|
        contact.as_json(
          include: { address: { include: { country: { only: :name } },
                                except: %i[created_at updated_at country_id] } },
          except: %i[created_at updated_at address_id]
        )
      end
      user_locs = current_user.user_addresses
      addresses = user_locs.map do |ul|
        { user: ul, address: ul.address.to_custom_hash } if ul.address.sandbox == @sandbox
      end

      resp = {
        shipments: shipments_hash,
        contacts: @contacts,
        num_contact_pages: (current_user.contacts.count.to_f / 6).to_f.ceil,
        addresses: addresses
      }
    end
    response_handler(response)
  end

  def show
    response_handler(merge_profile(user: current_user))
  end

  def account
    @user = current_user
    @addresses = @user.addresses.where(sandbox: @sandbox)

    { addresses: @addresses }
  end

  def update
    @user = current_user
    updating_guest_to_regular_user = current_user.guest
    @user.update(user_params)
    tenants_user = Tenants::User.find_by(legacy_id: @user.id)
    Profiles::ProfileService.create_or_update_profile(user: tenants_user,
                                                      first_name: user_profile_params[:first_name],
                                                      last_name: user_profile_params[:last_name],
                                                      company_name: user_profile_params[:company_name],
                                                      phone: user_profile_params[:phone])
    @user.send_confirmation_instructions if @user.valid? && !@user.guest && updating_guest_to_regular_user

    if params[:update][:address]
      address = Address.create_from_raw_params!(address_params.merge(sandbox: @sandbox))
      address.geocode_from_address_fields!
      @user.addresses << address unless address.nil?
    end

    headers = @user.create_new_auth_token
    response_handler(user: merge_profile(user: @user), headers: headers)
  end

  def currencies
    currency = current_user.try(:currency) || 'EUR'
    results = Legacy::CurrencyTools.new.get_currency_array(currency, params[:tenant_id])
    response_handler(results)
  end

  def download_gdpr
    url = DocumentService::GdprWriter.new(user_id: current_user.id).perform
    response_handler(url: url, key: 'gdpr')
  end

  def set_currency
    current_user.currency = params[:currency]
    current_user.save!
    rates = Legacy::CurrencyTools.new.get_rates(params[:currency], current_user.tenant_id)
    response_handler(user: merge_profile(user: current_user), rates: rates)
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
    response_handler(user: merge_profile(user: current_user))
  end

  private

  def user_params
    return_params = params.require(:update).permit(
      :guest, :tenant_id, :email, :password, :confirm_password, :password_confirmation,
      :vat_number, :VAT_number, :cookies, :company_number
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

  def user_profile_params
    params.require(:update).permit(%i[first_name last_name phone company_name])
  end

  def merge_profile(user:)
    ProfileTools.merge_profile(target: user.token_validation_response)
  end

  def shipments_hash
    quotation_tool? ?
    {
      quoted: quoted_shipments.order(booking_placed_at: :desc).limit(3)&.map(&:with_address_index_json)
    } : {
      requested: requested_shipments.order(booking_placed_at: :desc).limit(3)&.map(&:with_address_index_json)
    }
  end

  def requested_shipments
    @requested_shipments ||= current_user.shipments.where(sandbox: @sandbox).requested
  end

  def quoted_shipments
    @quoted_shipments ||= current_user.shipments.where(sandbox: @sandbox).quoted
  end

  def open_shipments
    @open_shipments ||= current_user.shipments.where(sandbox: @sandbox).open
  end

  def rejected_shipments
    @rejected_shipments ||= current_user.shipments.where(sandbox: @sandbox).rejected
  end

  def archived_shipments
    @archived_shipments ||= current_user.shipments.where(sandbox: @sandbox).archived
  end

  def finished_shipments
    @finished_shipments ||= current_user.shipments.where(sandbox: @sandbox).finished
  end

  def address_params
    params.require(:update).require(:address).permit(
      :street, :street_number, :zip_code, :city, :country
    )
  end
end
