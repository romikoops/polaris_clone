# frozen_string_literal: true

Trestle.resource(:memberships, model: Users::Membership) do
  search do |query|
    if query
      query = if (match = query.match(/\A"(.*)"\z/))
        match[1]
      else
        "%#{query}%"
      end

      collection
        .joins(:user)
        .joins(:organization)
        .where("users_users.email ILIKE :query OR organizations_organizations.slug ILIKE :query", query: query)
    else
      collection
    end
  end

  table do
    column :user, link: false
    column :organization, ->(membership) { membership.organization.slug }
    column :role

    actions
  end

  form do |_membership|
    collection_select :user_id, Users::User.all, :id, :email
    collection_select :organization_id, Organizations::Organization.all, :id, :slug
    select :role, Users::Membership.roles.keys
  end
end
