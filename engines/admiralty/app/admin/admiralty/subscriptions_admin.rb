# frozen_string_literal: true

Trestle.resource(:subscriptions, model: Notifications::Subscription) do
  menu :subscriptions, icon: "fa fa-envelope-open-text", group: :notifications

  sort_column(:organization) do |collection, order|
    collection.joins(:organization).reorder("organizations_organizations.slug #{order}")
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
        .where("\
          notifications_subscriptions.email ILIKE :query \
          OR event_type ILIKE :query \
          OR organizations_organizations.slug ILIKE :query
          ", query: query)
    else
      collection
    end
  end

  collection do
    Notifications::Subscription.where(user_id: nil).order(email: :asc)
  end

  table do
    column :organization, ->(membership) { membership.organization.slug }, sort: :organization
    column :email, link: false, sort: { default: true }
    column :event_type
    actions
  end

  form do |_subscription|
    collection_select :organization_id, Organizations::Organization.all, :id, :slug
    text_field :email
    collection_select :mode_of_transports, Journey::RouteSection.select("DISTINCT(mode_of_transport)").to_ary, :mode_of_transport, :mode_of_transport, { include_blank: true }
    collection_select :origins, Legacy::Nexus.distinct(:locode), :locode, :locode, { default: nil, include_blank: true }
    collection_select :destinations, Legacy::Nexus.distinct(:locode), :locode, :locode, { default: nil, include_blank: true }
    collection_select :groups, Groups::Group.all, :id, :name, { default: nil, include_blank: true }
    select :event_type, (RailsEventStore::Event.descendants - [RubyEventStore::Proto]).map(&:to_s).sort.uniq
  end
end
