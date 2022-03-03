# frozen_string_literal: true

module Users
  class ClientProfile < ApplicationRecord
    include PgSearch::Model

    belongs_to :user, class_name: "Users::Client"

    validates :first_name, presence: true, allow_blank: true
    validates :last_name, presence: true, allow_blank: true

    pg_search_scope :search, against: %i[first_name last_name company_name phone],
                             associated_against: {
                               user: %i[email]
                             },
                             using: {
                               tsearch: { prefix: true }
                             }
    pg_search_scope :email_search, associated_against: { user: %i[email] },
                                   using: {
                                     tsearch: { prefix: true }
                                   }

    pg_search_scope :first_name_search, against: %i[first_name], using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :last_name_search, against: %i[last_name], using: {
      tsearch: { prefix: true }
    }

    acts_as_paranoid

    def full_name
      [first_name, last_name].compact.join(" ")
    end
    alias name full_name
    delegate :email, :settings, to: :user, allow_nil: true
    delegate :currency, :language, :locale, to: :settings, allow_nil: true
  end
end

# == Schema Information
#
# Table name: users_client_profiles
#
#  id           :uuid             not null, primary key
#  company_name :string
#  deleted_at   :datetime
#  first_name   :string
#  last_name    :string
#  phone        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  external_id  :string
#  user_id      :uuid
#
# Indexes
#
#  index_users_client_profiles_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users_clients.id) ON DELETE => cascade
#
