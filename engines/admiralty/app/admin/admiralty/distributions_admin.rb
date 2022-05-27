# frozen_string_literal: true

Trestle.resource(:distributions, model: Distributions::Action) do
  menu :distributions, icon: "fa fa-arrows", group: :organizations

  search do |query|
    if query
      collection = collection.joins(:organization).joins(:target_organization)
      collection.where("organizations.slug ILIKE ? OR target_organizations.slug ILIKE ?", "%#{query}%", "%#{query}%").or(
        collection.where("upload_schema ILIKE ?", "%#{query}%")
      )
    else
      collection
    end
  end

  table do
    column :organization, ->(action) { action.organization.slug }
    column :target_organization, ->(action) { action.target_organization.slug }
    column :where, ->(action) { action.where }
    column :arguments, ->(action) { action.arguments }

    actions
  end

  form do
    row do
      col(sm: 6) { collection_select :organization_id, Organizations::Organization.all, :id, :slug }
      col(sm: 6) { collection_select :target_organization_id, Organizations::Organization.all, :id, :slug }
    end

    row do
      col(sm: 6) { text_field :upload_schema }
      col(sm: 6) { number_field :order }
    end

    row do
      col(sm: 6) { json_editor :where }
      col(sm: 6) { json_editor :arguments }
    end
  end
end
