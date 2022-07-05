# frozen_string_literal: true

module Tracker
  class UsersInteraction < ApplicationRecord
    belongs_to :client, class_name: "Users::Client"
    belongs_to :interaction
    validates :client_id, uniqueness: { scope: :interaction_id }

    default_scope do
      joins(:interaction)
        .select("tracker_users_interactions.*, tracker_interactions.name, tracker_interactions.organization_id")
        .where(tracker_interactions: { organization_id: ::Organizations.current_id })
    end
  end
end

# == Schema Information
#
# Table name: tracker_users_interactions
#
#  id             :uuid             not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  client_id      :uuid
#  interaction_id :uuid
#
# Indexes
#
#  index_tracker_users_interactions_on_client_id       (client_id)
#  index_tracker_users_interactions_on_interaction_id  (interaction_id)
#  index_users_interactions_on_client_id               (client_id,interaction_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (client_id => users_clients.id)
#  fk_rails_...  (interaction_id => tracker_interactions.id)
#
