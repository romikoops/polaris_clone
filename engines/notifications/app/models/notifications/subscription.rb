# frozen_string_literal: true
module Notifications
  class Subscription < ApplicationRecord
    belongs_to :user, optional: true, class_name: "Users::User"
    belongs_to :organization, class_name: "Organizations::Organization"
  end
end

# == Schema Information
#
# Table name: notifications_subscriptions
#
#  id              :bigint           not null, primary key
#  email           :string
#  event_type      :string
#  filter          :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  user_id         :uuid
#
# Indexes
#
#  index_notifications_subscriptions_on_email            (email)
#  index_notifications_subscriptions_on_event_type       (event_type)
#  index_notifications_subscriptions_on_organization_id  (organization_id)
#  index_notifications_subscriptions_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (user_id => users_users.id)
#
