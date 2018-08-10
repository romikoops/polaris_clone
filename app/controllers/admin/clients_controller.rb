# frozen_string_literal: true

class Admin::ClientsController < Admin::AdminBaseController
  # Return all clients and managers for dashboard

  def index
    shipper_role = Role.find_by_name("shipper")
    manager_role = Role.find_by_name("sub_admin")
    clients = User.where(tenant_id: current_user.tenant_id, role_id: shipper_role.id, guest: false).map(&:for_admin_json)

    managers = User.where(tenant_id: current_user.tenant_id, role_id: manager_role.id)
    response_handler(clients: clients, managers: managers)
  end

  # Return selected User, assigned managers, shipments made and user locations

  def show
    client = User.find(params[:id])
    locations = client.locations
    shipments = client.shipments.where(status: %w[requested open in_progress finished]).map(&:with_address_options_json)
    manager_assignments = UserManager.where(user_id: client)
    resp = { client: client, locations: locations, shipments: shipments, managerAssignments: manager_assignments }
    response_handler(resp)
  end

  # Api end point to create a new User through the Admin Dashboard
  def create
    json = JSON.parse(params[:new_client])
    user_data = {
      email:                 json["email"],
      company_name:          json["companyName"],
      first_name:            json["firstName"],
      phone:                 json["phone"],
      last_name:             json["lastName"],
      password:              json["password"],
      password_confirmation: json["password_confirmation"]
    }
    new_user = current_user.tenant.users.create!(user_data)

    response_handler(new_user.token_validation_response)
  end

  # Destroy User account

  def destroy
    User.find(params[:id]).destroy
    response_handler(params[:id])
  end
end
