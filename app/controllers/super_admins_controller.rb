class SuperAdminsController < ApplicationController # TODO: mongo
  # before_action :require_login_and_role_is_super_admin
  include MultiTenantTools
  include Response
  def new_demo_site
    if params[:file]
      tenant = JSON.parse(File.read(params[:file].tempfile))
      new_site(tenant, true)
      response_handler(true)
    else
      response_handler(false)
    end
  end
  private

  def require_login_and_role_is_super_admin
    unless user_signed_in? && current_user.role.name == "super_admin"
      response_handler(false)
    end
  end
end
