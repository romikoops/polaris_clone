class Admin::UserManagersController < ApplicationController
before_action :require_login_and_role_is_admin

  def assign
    assign_data = params[:obj].as_json
    client = User.find(assign_data["client_id"])
    manager = User.find(assign_data["manager_id"])
    new_manager = client.user_managers.create(manager_id: manager.id, section: assign_data["role"])
    response_handler(new_manager)
  end

private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
