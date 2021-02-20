# frozen_string_literal: true

Trestle.resource(:clients, model: Users::Client) do
  menu :clients, icon: "fa fa-users", group: :users

  collection do
    Users::Client.unscoped.order(created_at: :desc)
  end

  instance do |params|
    Users::Client.unscoped.find(params[:id])
  end

  sort_column(:organization) do |collection, order|
    collection.joins(:organization).reorder("organizations_organizations.slug #{order}")
  end

  sort_column(:first_name) do |collection, order|
    collection.joins(:profile).reorder("users_client_profiles.first_name #{order}")
  end

  sort_column(:last_name) do |collection, order|
    collection.joins(:profile).reorder("users_client_profiles.last_name #{order}")
  end

  search do |query|
    if query
      collection
        .joins(:organization)
        .joins(:profile)
        .where("email ILIKE :query \
          OR users_client_profiles.first_name ILIKE :query \
          OR users_client_profiles.last_name ILIKE :query \
          OR organizations_organizations.slug ILIKE :query",
          query: "%#{query}%")
    else
      collection
    end
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :email, link: true
    column :first_name, -> (user) { user.profile.first_name }, sort: :first_name
    column :last_name, -> (user) { user.profile.last_name }, sort: :last_name
    column :organization, -> (user) { user.organization.slug }, sort: :organization
    column :last_login_at
    column :last_activity_at
    column :activation_state
    column :created_at, sort: {default: true, default_order: :desc}
  end

  form do |user|
    text_field :email

    password_field :password
    password_field :password_confirmation

    select :activation_state, %w[active pending]

    collection_select :organization_id, Organizations::Organization.all, :id, :slug
  end
end
