# frozen_string_literal: true

Trestle.resource(:clients, model: Api::Client) do
  menu :clients, icon: "fa fa-users", group: :users

  collection do
    Api::Client.unscoped.order(created_at: :desc)
  end

  instance do |params|
    Api::Client.unscoped.find(params[:id])
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
      query = if (match = query.match(/\A"(.*)"\z/))
        match[1]
      else
        "%#{query}%"
      end

      collection
        .joins(:organization)
        .joins(:profile)
        .where("email ILIKE :query \
          OR users_client_profiles.first_name ILIKE :query \
          OR users_client_profiles.last_name ILIKE :query \
          OR organizations_organizations.slug ILIKE :query",
          query: query)
    else
      collection
    end
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :email, link: true
    column :first_name, ->(user) { user.profile.first_name }, sort: :first_name
    column :last_name, ->(user) { user.profile.last_name }, sort: :last_name
    column :organization, ->(user) { user.organization.slug }, sort: :organization
    column :last_login_at
    column :last_activity_at
    column :activation_state
    column :created_at, sort: { default: true, default_order: :desc }
  end

  form do |client|
    collection_select :organization_id, Organizations::Organization.all, :id, :slug

    text_field :email

    fields_for :profile, client.profile || client.build_profile do
      text_field :first_name
      text_field :last_name
    end

    fields_for :settings, client.settings || client.build_settings do
      text_field :locale
      text_field :language
    end

    password_field :password
    password_field :password_confirmation

    select :activation_state, %w[active pending]
  end
end
