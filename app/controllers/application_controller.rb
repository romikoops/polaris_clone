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

  def require_non_guest_authentication!
    raise ApplicationError::NotAuthenticated if current_user.guest?
  end

  private

  def current_tenant
    @current_tenant ||= current_user&.tenant
  end

  def set_raven_context
    tenant_scope = current_tenant&.scope
    Raven.user_context(
      email: current_user&.email,
      id: current_user&.id,
      ip: request.remote_ip
    )
    Raven.extra_context(
      params: params.to_unsafe_h,
      tenant: current_tenant&.subdomain,
      url: request.url,
      scope: {
        quotation_tool: tenant_scope&.slice('open_quotation_tool', 'closed_quotation_tool')&.values&.reduce(:|),
        beta_features: tenant_scope&.fetch('show_beta_features', false)
      }
    )
  end

  def clear_shoryuken
    file_path = Rails.root + '/log/shoryuken.log'
    File.delete(file_path)
  end
end
