class Admin::AdminBaseController < ApplicationController
  before_action :require_login_and_role_is_admin

  protected

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && is_current_tenant?
      # flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end

  def open_file(file)
    Roo::Spreadsheet.open(file)
  end

  def is_current_tenant?
    current_user.tenant_id === params[:tenant_id]
  end
end
