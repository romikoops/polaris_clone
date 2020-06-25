# frozen_string_literal: true

module Profiles
  class Profile < ApplicationRecord
    validates :user_id, uniqueness: true

    acts_as_paranoid

    include PgSearch::Model
    pg_search_scope :search, against: %i[first_name last_name company_name phone], using: {
      tsearch: { prefix: true }
    }

    pg_search_scope :first_name_search, against: %i[first_name], using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :last_name_search, against: %i[last_name], using: {
      tsearch: { prefix: true }
    }
  end
end

# == Schema Information
#
# Table name: profiles_profiles
#
#  id           :uuid             not null, primary key
#  company_name :string
#  deleted_at   :datetime
#  first_name   :string           default(""), not null
#  last_name    :string           default(""), not null
#  phone        :string
#  user_id      :uuid
#
# Indexes
#
#  index_profiles_profiles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => tenants_users.id) ON DELETE => cascade
#
