# frozen_string_literal: true

Trestle.resource(:tenant_cargo_item_types, model: Legacy::TenantCargoItemType) do
  menu :colli_types, icon: "fa fa-box", group: :organizations

  search do |query|
    filtered_collection = collection
      .joins(:organization)
      .joins(:cargo_item_types)
    if query
      filtered_collection.where("category ILIKE :query OR description ILIKE :query OR organizations_organizations.slug ILIKE :query", query: "%#{query}%")
    else
      filtered_collection
    end
  end

  sort_column(:organization) do |collection, order|
    collection
      .joins(:organization)
      .joins(:cargo_item_types)
      .reorder("organizations_organizations.slug #{order}")
  end

  table do
    column :organization, ->(tenant_cargo_item_type) { tenant_cargo_item_type.organization&.slug }, sort: :organization
    column :category, ->(tenant_cargo_item_type) { tenant_cargo_item_type.cargo_item_type&.category }
    column :description, ->(tenant_cargo_item_type) { tenant_cargo_item_type.cargo_item_type&.description }

    actions
  end

  form do
    select :organization, Organizations::Organization.all, :id, :slug
    select :cargo_item_type, Legacy::CargoItemType.where(width: nil, height: nil), :id, :description
  end
end
