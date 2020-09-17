# frozen_string_literal: true

module Users
  class Settings < ApplicationRecord
    belongs_to :user, class_name: 'Users::User'
    validates :user, uniqueness: true

    acts_as_paranoid
  end
end

# == Schema Information
#
# Table name: users_settings
#
#  id         :uuid             not null, primary key
#  currency   :string           default("EUR")
#  deleted_at :datetime
#  language   :string           default("en-GB")
#  locale     :string           default("en-GB")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_users_settings_on_deleted_at  (deleted_at)
#  index_users_settings_on_user_id     (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users_users.id)
#
