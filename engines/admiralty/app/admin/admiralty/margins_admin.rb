# frozen_string_literal: true

Trestle.resource(:margins, model: Pricings::Margin) do
  menu :margins, icon: "fa fa-percent", group: :organizations

  search do |query|
    if query
      query = if (match = query.match(/\A"(.*)"\z/))
        match[1]
      else
        "%#{query}%"
      end

      collection.joins(:organization).where("organizations_organizations.slug ILIKE :query", query: query)
    else
      collection
    end
  end

  table do
    column :organization, ->(margin) { margin.organization.slug }

    column :margin_type, ->(margin) { margin.margin_type.gsub("_margin", "") }
    column :default_for
    column :operator
    column :value

    actions
  end

  form do
    collection_select :organization_id, Organizations::Organization.all, :id, :slug

    row do
      col(sm: 3) { select :margin_type, Pricings::Margin.margin_types.keys }
      col(sm: 3) { select :default_for, ["rail", "ocean", "air", "truck", "local_charge", "trucking", nil] }
      col(sm: 3) { select :operator, ["+", "%"] }
      col(sm: 3) { number_field :value, label: "Value", help: "The margin value to be applied to the rates" }
    end
  end
end
