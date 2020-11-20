# frozen_string_literal: true

class Admin::UserManagersController < Admin::AdminBaseController
  def assign
    assign_data = params[:obj].as_json
    client = User.find(assign_data["client_id"])
    manager = User.find(assign_data["manager_id"])
    new_manager = client.user_managers.create(manager_id: manager.id, section: assign_data["role"])
    response_handler(new_manager)
  end
end
