class Admin::ClientsController < ApplicationController
  before_action :require_login_and_role_is_admin

  def index
    role = Role.find_by_name('shipper')
    @clients = User.where(tenant_id: current_user.tenant_id, role_id: role.id)
    response_handler(@clients)
  end

  

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name == "admin"
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end

end
