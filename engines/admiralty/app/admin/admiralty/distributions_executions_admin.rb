# frozen_string_literal: true

Trestle.resource(:distributions_executions, model: Distributions::Execution) do
  menu :distributions_executions, icon: "fa fa-rocket", group: :distributions
  remove_action :edit, :update, :destroy, :new, :create

  search do |query|
    if query
      collection = collection.joins(action: :organization)
      collection.where("organizations_organizations.slug ILIKE ?", "%#{query}%").or(
        collection.where("distributions_actions.upload_schema ILIKE ?", "%#{query}%")
      )
    else
      collection
    end
  end

  table do
    column :action, ->(execution) { execution.action.upload_schema }
    column :target_organization, ->(execution) { execution.action.target_organization.slug }
    column :executed_at, ->(execution) { execution.created_at }

    actions
  end
end
