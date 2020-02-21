# frozen_string_literal: true

module Profiles
  class Profile < ApplicationRecord
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
#  first_name   :string
#  image        :string
#  last_name    :string
#  phone        :string
#  user_id      :uuid
#
# Indexes
#
#  index_profiles_profiles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => tenants_users.id)
#
