# frozen_string_literal: true

require "#{Rails.root}/app/classes/application_error.rb"

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Response
  before_action :set_raven_context
  before_action :require_authentication!
  before_action :require_non_guest_authentication!
  before_action :set_paper_trail_whodunnit

  rescue_from ApplicationError do |error|
    response_handler(error)
  end

  def response_handler(res)
    if res.is_a? StandardError
      error_handler(res)
    else
      success_handler(res)
    end
  end

  def require_authentication!
    raise ApplicationError::NotAuthenticated unless user_signed_in?

    require_non_guest_authentication! if current_tenant.scope['closed_shop']
  end

  def get_tenant
    binding.pry
  end

  def require_non_guest_authentication!
    raise ApplicationError::NotAuthenticated if current_user.guest?
  end

  private

  def current_tenant
    @current_tenant ||= current_user&.tenant
  end

  def find_tenant
    @tenant = Tenant.find(params[:tenant_id])
  end
  
  def append_info_to_payload(payload)
    super
    payload[:tenant] = current_tenant&.subdomain
  end

  def set_raven_context
    Raven.user_context(
      email: current_user&.email,
      id: current_user&.id,
      ip: request.remote_ip
    )
    Raven.tags_context(
      agency: current_user&.agency_id&.present?,
      namespace: ENV['K8S_NAMESPACE'],
      tenant: current_tenant&.subdomain
    )
    Raven.extra_context(
      agency: current_user&.agency&.slice(%i(id name)),
      params: params.to_unsafe_h,
      url: request.url,
      scope: current_tenant&.scope
    )
  end

  def clear_shoryuken
    file_path = Rails.root + '/log/shoryuken.log'
    File.delete(file_path)
  end
end
