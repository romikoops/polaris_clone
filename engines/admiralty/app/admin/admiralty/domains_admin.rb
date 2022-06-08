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

  sort_column(:application) do |collection, order|
    collection.joins("LEFT JOIN oauth_applications ON oauth_applications.id = organizations_domains.application_id").reorder("oauth_applications.name #{order}")
  end

  table do
    column :organization, ->(domain) { domain.organization.slug }, sort: :organization
    column :application, ->(domain) { Doorkeeper::Application.find(domain.application_id).name if domain.application_id.present? }, sort: :application
    column :domain
    column :default

    actions
  end

  form do |_domain|
    collection_select :organization_id, Organizations::Organization.all, :id, :slug
    collection_select :application_id, Doorkeeper::Application.all, :id, :name
    text_field :domain
    check_box :default
  end
end
