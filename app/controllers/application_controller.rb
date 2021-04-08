# frozen_string_literal: true

class ApplicationController < Api::ApiController
  include Response

  before_action :set_paper_trail_whodunnit, except: [:health]

  skip_before_action :doorkeeper_authorize!, only: [:health]
  skip_before_action :set_organization_id, only: [:health]
  skip_before_action :ensure_organization!, only: [:health]

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  rescue_from ApplicationError do |error|
    response_handler(error)
  end

  def health
    head :ok
  end

  def response_handler(res)
    if res.is_a?(StandardError)
      error_handler(res)
    else
      success_handler(res)
    end
  end

  private

  def quotation_tool?
    current_scope["open_quotation_tool"] || current_scope["closed_quotation_tool"]
  end

  def append_info_to_payload(payload)
    super

    payload[:organization] = current_organization&.slug
    payload[:user_id] = current_user&.id
  end

  def inactivity_limit
    time = current_scope[:session_length]
    return 1.hour.seconds if time.nil?

    length = [time.to_i.seconds, 10.minutes].max
    length.seconds
  end

  def test_user?
    current_user&.email&.ends_with?("@itsmycargo.com")
  end

  def generate_token_for(user:, scope:)
    Doorkeeper::AccessToken.create(resource_owner_id: user.id,
                                   application: Doorkeeper::Application.find_by(name: "dipper"),
                                   refresh_token: generate_refresh_token,
                                   expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
                                   scopes: scope)
  end

  def generate_refresh_token
    loop do
      token = SecureRandom.hex(32)
      break token unless Doorkeeper::AccessToken.exists?(refresh_token: token)
    end
  end

  def role_for(user:)
    if user.organization_id.nil? &&
        ::Users::Membership.exists?(organization_id: current_organization.id, user_id: user.id)
      "admin"
    else
      "shipper"
    end
  end

  def decorate_results(results:)
    Api::V1::LegacyResultDecorator.decorate_collection(
      results,
      context: { scope: current_scope }
    )
  end

  def default_group
    @default_group ||= Groups::Group.find_by(name: "default", organization: current_organization)
  end
end
