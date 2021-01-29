# frozen_string_literal: true

module Users
  class ClientSettings < ApplicationRecord
    belongs_to :user, class_name: "Users::Client"

    validates :user, uniqueness: true
  end
end

# == Schema Information
#
# Table name: users_client_settings
#
#  id         :uuid             not null, primary key
#  currency   :string           default("EUR")
#  language   :string           default("en-GB")
#  locale     :string           default("en-GB")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_users_client_settings_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users_clients.id) ON DELETE => cascade
#
