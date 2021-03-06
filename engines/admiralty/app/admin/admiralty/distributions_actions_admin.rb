# frozen_string_literal: true

Trestle.resource(:distributions_actions, model: Distributions::Action) do
  menu :distributions_actions, icon: "fa fa-arrows", group: :distributions

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
      col(sm: 4) do
        select :upload_schema, %w[hubs
          clients
          grdb_xml_origin_charge
          schedules
          pricings
          grdb_excel
          trucking
          saco_import
          saco_pricings
          grdb_xml_destination_charge
          grdb_xml
          local_charge]
      end
      col(sm: 4) { number_field :order }
      col(sm: 4) do
        select :action_type, Distributions::Action.action_types.keys
      end
    end

    row do
      col(sm: 6) { json_editor :where }
      col(sm: 6) { json_editor :arguments }
    end
  end
end
