# frozen_string_literal: true

require "#{Rails.root}/app/classes/application_error.rb"

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Response
  before_action :set_sandbox
  before_action :set_raven_context
  before_action :require_authentication!
  before_action :require_non_guest_authentication!
  before_action :set_paper_trail_whodunnit

  skip_after_action :register_last_activity_time_to_db

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

    shop_requires_auth = current_scope.fetch('closed_shop')
    require_non_guest_authentication! if shop_requires_auth
  end

  def require_non_guest_authentication!
    raise ApplicationError::NotAuthenticated if current_user.guest?
  end

  private

  def current_tenant
    @current_tenant ||= Tenant.find_by(id: params[:tenant_id] || params[:id])
  end

  def current_scope
    @current_scope ||= ::Tenants::ScopeService.new(
      target: ::Tenants::User.find_by(legacy_id: current_user&.id),
      tenant: ::Tenants::Tenant.find_by(legacy_id: current_tenant&.id)
    ).fetch
  end

  def quotation_tool?
    current_scope['open_quotation_tool'] || current_scope['closed_quotation_tool']
  end

  def append_info_to_payload(payload)
    super

    payload[:tenant] = ::Tenants::Tenant.find_by(legacy_id: current_tenant&.id)&.slug
    payload[:user_id] = current_user&.id
  end

  def set_raven_context
    Raven.user_context(
      email: current_user&.email,
      id: current_user&.id,
      ip: request.remote_ip
    )
    Raven.tags_context(
      agency: current_user&.agency_id.present?,
      namespace: ENV['REVIEW_APP_NAME'],
      tenant: current_tenant && ::Tenants::Tenant.find_by(legacy_id: current_tenant.id)&.slug
    )
    Raven.extra_context(
      agency: current_user&.agency&.slice(%i(id name)),
      params: params.to_unsafe_h,
      url: request.url,
      scope: current_scope
    )
  end

  def set_sandbox
    @sandbox = Tenants::Sandbox.find_by(id: request.headers[:sandbox])
  end

  def clear_shoryuken
    file_path = Rails.root + '/log/shoryuken.log'
    File.delete(file_path)
  end
end
