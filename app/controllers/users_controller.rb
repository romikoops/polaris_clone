# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :doorkeeper_authorize!, only: %i[create activate passwordless_authentication]

  DASH_LIMIT = 3

  def home
    response = Rails.cache.fetch("#{client_results.cache_key}/dashboard_index", expires_in: 12.hours) do
      @contacts = Legacy::Contact.where(user: current_user).limit(6).map do |contact|
        contact.as_json(
          include: { address: { include: { country: { only: :name } },
                                except: %i[created_at updated_at country_id] } },
          except: %i[created_at updated_at address_id]
        )
      end
      user_locs = Legacy::UserAddress.where(user: current_user)
      addresses = user_locs.map do |ul|
        { user: ul, address: ul.address.to_custom_hash }
      end

      {
        shipments: shipments_hash,
        contacts: @contacts,
        num_contact_pages: (Legacy::Contact.where(user: current_user).count.to_f / 6).to_f.ceil,
        addresses: addresses
      }
    end
    response_handler(response)
  end

  def show
    response = complete_user_response(user: current_user)
    response[:organization_id] ||= Organizations.current_id
    response_handler(response)
  end

  def account
    user = current_user
    @addresses = Legacy::UserAddress.where(user: user).map(&:address)

    { addresses: @addresses }
  end

  def update
    user = current_user
    user.update(user_params.merge(profile_attributes: user_profile_params.merge(id: user.profile.id)))

    if params[:update][:address]
      address = Address.create_from_raw_params!(address_params)
      address.geocode_from_address_fields!
      Legacy::UserAddress.create(user: user, address: address) unless address.nil?
    end

    user_response = complete_user_response(user: user)
    token = generate_token_for(user: user, scope: "public")
    token_header = Doorkeeper::OAuth::TokenResponse.new(token).body

    response_handler(user: user_response, headers: token_header)
  end

  def create
    user = Api::ClientCreationService.new(
      client_attributes: new_user_params,
      profile_attributes: profile_params,
      settings_attributes: { currency: current_scope[:default_currency] }
    ).perform
    response = generate_token_for(user: user, scope: "public")
    response_handler(Doorkeeper::OAuth::TokenResponse.new(response).body)
  rescue ActiveRecord::RecordInvalid => e
    response_handler(
      ApplicationError.new(
        http_code: 422,
        message: e.message
      )
    )
  end

  def passwordless_authentication
    not_authenticated && return if current_scope.dig(:signup_form_fields, :password)
    raise ActiveRecord::RecordInvalid if passwordless_new_user_params[:email].blank?

    user = Users::Client.find_by(passwordless_new_user_params)
    user ||= Users::Client.new(passwordless_new_user_params.merge(profile_attributes: profile_params))
    ActiveRecord::Base.transaction do
      user.save!
      response = generate_token_for(user: user, scope: "public")
      response_handler(Doorkeeper::OAuth::TokenResponse.new(response).body)
    end
  rescue ActiveRecord::RecordInvalid => e
    response_handler(
      ApplicationError.new(
        http_code: 422,
        message: e.message
      )
    )
  end

  def download_gdpr
    url = DocumentService::GdprWriter.new(user_id: current_user.id).perform
    response_handler(url: url, key: "gdpr")
  end

  def set_currency
    Users::ClientSettings.find_by(user: current_user)&.update(currency: params[:currency])
    response = complete_user_response(user: current_user)
    response_handler(user: response)
  end

  def hubs
    @hubs = Hub.prepped(current_user)

    response_handler(@hubs)
  end

  def activate
    @user = ::Users::User.load_from_activation_token(params[:id]) ||
      ::Users::Client.load_from_activation_token(params[:id])
    if @user
      @user.activate!

      response_handler(@user)
    else
      not_authenticated
    end
  end

  private

  def not_authenticated
    render json: { success: false }, status: :unauthorized
  end

  def new_user_params
    params.require(:user).permit(:email, :password, :organization_id)
  end

  def passwordless_new_user_params
    params.require(:user).permit(:email, :organization_id)
  end

  def profile_params
    params.require(:user).permit(%i[first_name last_name phone company_name])
  end

  def user_params
    return_params = params.require(:update).permit(
      :organization_id, :email, :password, :cookies
    ).to_h

    return_params[:password_confirmation] = return_params.delete(:confirm_password) unless return_params[:confirm_password].nil?

    unless return_params[:cookies].nil?
      return_params.delete(:cookies)
      return_params[:optin_status_id] = OptinStatus
        .find_by(tenant: !params[:guest], itsmycargo: !params[:guest], cookies: true)
        .id
    end

    return_params
  end

  def user_profile_params
    params.require(:update).permit(%i[first_name last_name phone company_name external_id])
  end

  def merge_profile(user:)
    ProfileTools.merge_profile(target: user)
  end

  def shipments_hash
    {
      quoted: decorate_results(results: client_results.order(created_at: :desc).limit(DASH_LIMIT))
        .map(&:legacy_index_json)
    }
  end

  def address_params
    params.require(:update).require(:address).permit(
      :street, :street_number, :zip_code, :city, :country
    )
  end

  def complete_user_response(user:)
    role = { name: role_for(user: user) }
    currency = user.settings&.currency
    user_metadata = { role: role, inactivityLimit: inactivity_limit, currency: currency }
    merge_profile(user: user).merge(user_metadata)
  end

  def client_results
    @client_results ||= Journey::Result.joins(result_set: :query).joins(:route_sections)
      .where(
        journey_result_sets: { status: "completed" },
        journey_queries: { client_id: current_user.id, organization_id: current_organization.id }
      )
  end
end
