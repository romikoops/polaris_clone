# frozen_string_literal: true

module Profiles
  class Profile < ApplicationRecord
    validates :user_id, uniqueness: true
    validates :first_name, presence: true, allow_blank: true
    validates :last_name, presence: true, allow_blank: true

    belongs_to :user, class_name: "Users::User", foreign_key: :user_id

    acts_as_paranoid

    include PgSearch::Model
    pg_search_scope :search, against: %i[first_name last_name company_name phone], using: {
      tsearch: {prefix: true}
    }

    pg_search_scope :first_name_search, against: %i[first_name], using: {
      tsearch: {prefix: true}
    }
    pg_search_scope :last_name_search, against: %i[last_name], using: {
      tsearch: {prefix: true}
    }

    def full_name
      [first_name, last_name].compact.join(" ")
    end
  end
end

# == Schema Information
#
# Table name: profiles_profiles
#
#  id             :uuid             not null, primary key
#  company_name   :string
#  deleted_at     :datetime
#  first_name     :string           default(""), not null
#  last_name      :string           default(""), not null
#  phone          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  external_id    :string
#  legacy_user_id :uuid
#  user_id        :uuid
#
# Indexes
#
#  index_profiles_profiles_on_legacy_user_id  (legacy_user_id)
#  index_profiles_profiles_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users_users.id)
#
