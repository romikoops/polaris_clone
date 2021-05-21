# frozen_string_literal: true

Trestle.resource(:admins, model: Users::User) do
  menu :admins, icon: "fa fa-id-badge", group: :users

  collection do
    Users::User.order(created_at: :desc)
  end

  sort_column(:first_name) do |collection, order|
    collection.joins(:profile).reorder("users_profiles.first_name #{order}")
  end

  sort_column(:last_name) do |collection, order|
    collection.joins(:profile).reorder("users_profiles.last_name #{order}")
  end

  search do |query|
    if query
      collection
        .joins(:profile)
        .where("email ILIKE :query \
        OR users_profiles.first_name ILIKE :query\
        OR users_profiles.last_name ILIKE :query",
          query: "%#{query}%")
    else
      collection
    end
  end

  table do
    column :email, link: true
    column :first_name, ->(user) { user.profile.first_name }, sort: :first_name
    column :last_name, ->(user) { user.profile.last_name }, sort: :last_name

    column :last_login_at
    column :last_activity_at
    column :activation_state
    column :created_at, sort: { default: true, default_order: :desc }
  end

  form do |user|
    tab :user do
      text_field :email

      password_field :password
      password_field :password_confirmation

      select :activation_state, %w[active pending]

      fields_for :profile, user.profile || user.build_profile do
        text_field :first_name
        text_field :last_name
      end

      fields_for :settings, user.settings || user.build_settings do
        text_field :locale
        text_field :language
      end
    end

    tab :memberships, badge: user.memberships.size do
      table user.memberships, admin: :memberships do
        column :organization do |membership|
          membership.organization.slug
        end
        actions
      end

      concat admin_link_to("New Membership", admin: :memberships, action: :new, params: { membership: { user_id: user.id } }, class: "btn btn-success")
    end
  end
end
