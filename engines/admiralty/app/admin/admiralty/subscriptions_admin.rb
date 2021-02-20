# frozen_string_literal: true

Trestle.resource(:subscriptions, model: Notifications::Subscription) do
  menu :subscriptions, icon: "fa fa-envelope-open-text", group: :notifications

  search do |query|
    if query
      collection
        .where("notifications_subscriptions.email ILIKE :query OR event_type ILIKE :query", query: "%#{query}%")
    else
      collection
    end
  end

  collection do
    Notifications::Subscription.where(user_id: nil).order(email: :asc)
  end

  table do
    column :email, link: false, sort: { default: true }
    column :event_type

    actions
  end

  form do |subscription|
    text_field :email
    select :event_type, (RailsEventStore::Event.descendants - [RubyEventStore::Proto]).map(&:to_s).sort.uniq
  end
end
