# frozen_string_literal: true

Trestle.resource(:charge_categories, model: Legacy::ChargeCategory) do
  menu :charge_categories, icon: "fa fa-language", group: :organizations

  search do |query|
    if query
      col = collection
        .joins(:organization)
        .where(cargo_unit_id: nil)
        .where.not(organization_id: nil)
      col.where("organizations_organizations.slug ILIKE :query", query: "%#{query}%").or(
        col.where("code ILIKE :query", query: "%#{query}%")
      ).or(
        col.where("name ILIKE :query", query: "%#{query}%")
      )
    else
      collection
        .where(cargo_unit_id: nil)
        .where.not(organization_id: nil)
    end
  end

  table do
    column :organization, -> (charge_category) { charge_category.organization.slug }

    column :code
    column :name

    actions
  end

  form do |charge_category|
    collection_select :organization_id, Organizations::Organization.all, :id, :slug

    row do
      col(sm: 4) { text_field :code, label: "Code", help: "Fee code used to indentify the fee on Pricing upload sheets" }
      col(sm: 4) { text_field :name, label: "Name", help: "The name of the Fee that is rendered on all Rates" }
    end
  end
end
