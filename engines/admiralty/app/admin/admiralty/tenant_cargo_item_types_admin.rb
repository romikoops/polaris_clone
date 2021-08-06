# frozen_string_literal: true

Trestle.resource(:tenant_cargo_item_types, model: Legacy::TenantCargoItemType) do
  menu :colli_types, icon: "fa fa-box", group: :organizations

  search do |query|
    filtered_collection = collection
      .joins(:organization)
      .joins(:cargo_item_type)
    if query
      query = if (match = query.match(/\A"(.*)"\z/))
        match[1]
      else
        "%#{query}%"
      end

      filtered_collection.where(
        "category ILIKE :query OR description ILIKE :query OR organizations_organizations.slug ILIKE :query",
        query: query
      )
    else
      filtered_collection
    end
  end

  sort_column(:organization) do |collection, order|
    collection
      .joins(:organization)
      .joins(:cargo_item_type)
      .reorder("organizations_organizations.slug #{order}")
  end

  table do
    column :organization, ->(tenant_cargo_item_type) { tenant_cargo_item_type.organization&.slug }, sort: :organization
    column :category, ->(tenant_cargo_item_type) { tenant_cargo_item_type.cargo_item_type&.category }
    column :description, ->(tenant_cargo_item_type) { tenant_cargo_item_type.cargo_item_type&.description }

    actions
  end

  form do
    row do
      col(sm: 6) { collection_select :organization_id, Organizations::Organization.all, :id, :slug }
      col(sm: 6) { collection_select :cargo_item_type_id, Legacy::CargoItemType.where(width: nil, length: nil), :id, :description }
    end
  end
end
