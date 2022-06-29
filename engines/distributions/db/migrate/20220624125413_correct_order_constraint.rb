# frozen_string_literal: true

class CorrectOrderConstraint < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    remove_index :distributions_actions, { name: "index_distributions_actions_on_order" }
    add_index :distributions_actions, %i[organization_id target_organization_id order upload_schema], unique: true, name: "index_distributions_actions_on_order", algorithm: :concurrently
  end
end
