# frozen_string_literal: true

Trestle.resource(:domains, model: Organizations::Domain) do
  menu :domains, icon: "fa fa-globe", group: :organizations

  search do |query|
    if query
      query = if (match = query.match(/\A"(.*)"\z/))
        match[1]
      else
        "%#{query}%"
      end

      collection
        .joins(:organization)
        .where("domain ILIKE :query OR organizations_organizations.slug ILIKE :query", query: query)
    else
      collection
    end
  end

  sort_column(:organization) do |collection, order|
    collection.joins(:organization).reorder("organizations_organizations.slug #{order}")
  end

  table do
    column :organization, ->(domain) { domain.organization.slug }, sort: :organization
    column :domain
    column :default

    actions
  end

  form do |_domain|
    collection_select :organization_id, Organizations::Organization.all, :id, :slug
    text_field :domain
    check_box :default
  end
end
