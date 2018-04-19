class Admin::ClientsController < ApplicationController
  before_action :require_login_and_role_is_admin
  
  # Return all clients and managers for dashboard
  
  def index
    shipper_role = Role.find_by_name('shipper')
    manager_role = Role.find_by_name('sub_admin')
    clients = User.where(tenant_id: current_user.tenant_id, role_id: shipper_role.id, guest: false)
    managers = User.where(tenant_id: current_user.tenant_id, role_id: manager_role.id)
    response_handler({clients: clients, managers: managers})
  end

  # Return selected User, assigned managers, shipments made and user locations

  def show
    client = User.find(params[:id])
    locations = client.locations
    shipments = client.shipments.where(status: ["requested", "open", "finished"])
    manager_assignments = UserManager.where(user_id: client)
    resp = {client: client, locations: locations, shipments: shipments, managerAssignments: manager_assignments}
    response_handler(resp)
  end

  # Api end point to create a new User through the Admin Dashboard
  def create
    json = JSON.parse(params[:new_client])
    user_data = {
      email: json["email"],
      company_name: json["companyName"],
      first_name: json["firstName"],
      phone: json["phone"],
      last_name: json["lastName"],
      password: json["password"],
      password_confirmation: json["password_confirmation"]
    }
    new_user = current_user.tenant.users.create!(user_data)

    response_handler(new_user)
  end

  # Destroy User account

  def destroy
    User.find(params[:id]).destroy
    response_handler(params[:id])
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end

end
