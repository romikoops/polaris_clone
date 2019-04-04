# frozen_string_literal: true

class Admin::ClientsController < Admin::AdminBaseController
  # Return all clients and managers for dashboard

  def index
    shipper_role = Role.find_by_name('shipper')
    manager_role = Role.find_by_name('sub_admin')

    clients = User.where(tenant_id: current_user.tenant_id, role_id: shipper_role.id, guest: false).map(&:for_admin_json)
    managers = User.where(tenant_id: current_user.tenant_id, role_id: manager_role.id)

    unless current_user.internal
      clients = clients.reject { |client| client['internal'] }
      managers = managers.reject { |manager| manager['internal'] }
    end
    response_handler(clients: clients, managers: managers)
  end

  # Return selected User, assigned managers, shipments made and user addresses

  def show
    client = User.find(params[:id])
    addresses = client.addresses
    shipments = client.shipments.where(status: %w(requested requested_by_unconfirmed_account)).map(&:with_address_options_json)
    manager_assignments = UserManager.where(user_id: client)
    resp = { client: client, addresses: addresses, shipments: shipments, managerAssignments: manager_assignments }
    response_handler(resp)
  end

  # Api end point to create a new User through the Admin Dashboard
  def create
    json = JSON.parse(params[:new_client])
    user_data = {
      email: json['email'],
      company_name: json['companyName'],
      first_name: json['firstName'],
      phone: json['phone'],
      last_name: json['lastName'],
      password: json['password'],
      password_confirmation: json['password_confirmation']
    }
    new_user = current_user.tenant.users.create!(user_data)

    response_handler(new_user.token_validation_response)
  end

  def agents
    req = { 'xlsx' => params[:file] }
    resp = ExcelTool::AgentsOverwriter.new(params: req, _user: current_user).perform
    response_handler(resp)
  end

  # Destroy User account

  def destroy
    User.find(params[:id]).destroy
    response_handler(params[:id])
  end
end
