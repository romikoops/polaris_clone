# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :doorkeeper_authorize!, only: [:currencies, :create, :activate]

  def home
    current_shipments = organization_user_shipments
    response = Rails.cache.fetch("#{current_shipments.cache_key}/dashboard_index", expires_in: 12.hours) do
      @contacts = Legacy::Contact.where(user: organization_user).limit(6).map do |contact|
        contact.as_json(
          include: { address: { include: { country: { only: :name } },
                                except: %i[created_at updated_at country_id] } },
          except: %i[created_at updated_at address_id]
        )
      end
      user_locs = Legacy::UserAddress.where(user: organization_user)
      addresses = user_locs.map do |ul|
        { user: ul, address: ul.address.to_custom_hash } if ul.address.sandbox == @sandbox
      end

      {
        shipments: shipments_hash,
        contacts: @contacts,
        num_contact_pages: (Legacy::Contact.where(user: organization_user).count.to_f / 6).to_f.ceil,
        addresses: addresses
      }
    end
    response_handler(response)
  end

  def show
    response = complete_user_response(user: organization_user)
    response[:organization_id] ||= Organizations.current_id
    response_handler(response)
  end

  def account
    user = organization_user
    @addresses = Legacy::UserAddress.where(user: user, sandbox: @sandbox).map(&:address)

    { addresses: @addresses }
  end

  def update
    user = organization_user
    user.update(user_params)
    update_profile_from_params(user: user, params: user_profile_params)
    # @user.send_confirmation_instructions if @user.valid? && !@user.guest && updating_guest_to_regular_user

    if params[:update][:address]
      address = Address.create_from_raw_params!(address_params.merge(sandbox: @sandbox))
      address.geocode_from_address_fields!
      unless address.nil?
        Legacy::UserAddress.create(user: user, address: address)
      end
    end

    user_response = complete_user_response(user: user)
    token = generate_token_for(user: user, scope: 'public')
    token_header = Doorkeeper::OAuth::TokenResponse.new(token).body

    response_handler(user: user_response, headers: token_header)
  end

  def create
    begin
      user = Authentication::User.new(new_user_params).tap do |u|
        u.type = 'Organizations::User' if new_user_params[:organization_id].present?
      end
      user.save!
      Profiles::ProfileService.create_or_update_profile(user: user,
                                                        first_name: profile_params[:first_name],
                                                        last_name: profile_params[:last_name],
                                                        company_name: profile_params[:company_name])
      response = generate_token_for(user: user, scope: 'public')
      response_handler(Doorkeeper::OAuth::TokenResponse.new(response).body)
    rescue ActiveRecord::RecordInvalid => e
      response_handler(
        ApplicationError.new(
          http_code: 422,
          message: user.errors
        )
      )
    end
  end

  def download_gdpr
    url = DocumentService::GdprWriter.new(user_id: organization_user.id).perform
    response_handler(url: url, key: 'gdpr')
  end

  def set_currency
    Users::Settings.find_by(user: organization_user)&.update(currency: params[:currency])
    response = complete_user_response(user: organization_user)
    response_handler(user: response)
  end

  def hubs
    @hubs = Hub.prepped(organization_user)

    response_handler(@hubs)
  end

  def activate
    if (@user = Authentication::User.load_from_activation_token(params[:id]))
      @user.activate!
      WelcomeMailer.welcome_email(@user).deliver_later
      NewUserMailer.new_user_email(user: @user).deliver_later if current_scope[:email_on_registration]

      response_handler(@user)
    else
      not_authenticated
    end
  end

  private

  def not_authenticated
    render json: {success: false}, status: 401
  end

  def new_user_params
    params.require(:user).permit(:email, :password, :organization_id)
  end

  def profile_params
    params.require(:user).permit(%i[first_name last_name phone company_name])
  end

  def user_params
    return_params = params.require(:update).permit(
      :organization_id, :email, :password, :cookies
    ).to_h

    unless return_params[:confirm_password].nil?
      return_params[:password_confirmation] = return_params.delete(:confirm_password)
    end

    unless return_params[:cookies].nil?
      return_params.delete(:cookies)
      return_params[:optin_status_id] = OptinStatus.find_by(tenant: !params[:guest], itsmycargo: !params[:guest], cookies: true).id
    end

    return_params
  end

  def user_profile_params
    params.require(:update).permit(%i[first_name last_name phone company_name external_id])
  end

  def merge_profile(user:)
    ProfileTools.merge_profile(target: user.attributes)
  end

  def shipments_hash
    quotation_tool? ?
    {
      quoted: decorate_shipments(shipments: quoted_shipments.order(booking_placed_at: :desc).limit(3)).map(&:legacy_index_json)
    } : {
      requested: decorate_shipments(shipments: requested_shipments.order(booking_placed_at: :desc).limit(3)).map(&:legacy_index_json)
    }
  end

  def requested_shipments
    @requested_shipments ||= organization_user_shipments.requested
  end

  def quoted_shipments
    @quoted_shipments ||= organization_user_shipments.quoted
  end

  def open_shipments
    @open_shipments ||= organization_user_shipments.open
  end

  def rejected_shipments
    @rejected_shipments ||= organization_user_shipments.rejected
  end

  def archived_shipments
    @archived_shipments ||= organization_user_shipments.archived
  end

  def finished_shipments
    @finished_shipments ||= organization_user_shipments.finished
  end

  def address_params
    params.require(:update).require(:address).permit(
      :street, :street_number, :zip_code, :city, :country
    )
  end

  def organization_user_shipments
    @organization_user_shipments ||= Legacy::Shipment.where(user: organization_user)
  end

  def complete_user_response(user:)
    role = { name: role_for(user: user) }
    currency = Users::Settings.find_by(user_id: user.id)&.currency
    user_metadata = {role: role, inactivityLimit: inactivity_limit, currency: currency}
    merge_profile(user: user).merge(user_metadata)
  end

  def update_profile_from_params(user:, params:)
    Profiles::ProfileService.create_or_update_profile(user: user,
                                                      first_name: params[:first_name],
                                                      last_name: params[:last_name],
                                                      external_id: params[:external_id],
                                                      company_name: params[:company_name])
  end
end
