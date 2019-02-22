# frozen_string_literal: true

class SuperAdminsController < ApplicationController
  before_action :require_login_and_role_is_super_admin
  include MultiTenantTools
  include Response
  include AwsConfig

  def new_demo_site
    if params[:file]
      tenant = JSON.parse(File.read(params[:file].tempfile))
      new_site(tenant, true)
      response_handler(true)
    else
      response_handler(false)
    end
  end

  def upload_image
    file = params[:file]
    obj_key = 'images/demo_images/' + file.original_filename
    save_asset(file, obj_key)

    response_handler(url: (asset_url << obj_key).to_s)
  end

  private

  def require_login_and_role_is_super_admin
    response_handler(false) unless user_signed_in? && current_user.role.name == 'super_admin'
  end
end
