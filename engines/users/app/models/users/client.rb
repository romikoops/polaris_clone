# frozen_string_literal: true

module Users
  class Client < ::Users::Base
    include PgSearch::Model
    self.inheritance_column = nil

    default_scope { where(organization_id: ::Organizations.current_id) }
    scope :global, -> { unscoped.where(deleted_at: nil) }

    belongs_to :organization, class_name: "Organizations::Organization"

    has_one :profile, class_name: "Users::ClientProfile", inverse_of: :user,
                      foreign_key: :user_id, required: true

    accepts_nested_attributes_for :profile

    has_one :settings, class_name: "Users::ClientSettings", inverse_of: :user,
                       foreign_key: :user_id, required: true
    accepts_nested_attributes_for :settings

    validates :email, presence: true, uniqueness: { scope: :organization_id },
                      format: { with: URI::MailTo::EMAIL_REGEXP }

    acts_as_paranoid

    pg_search_scope :email_search, against: %i[email], using: { tsearch: { prefix: true, any_word: true } }

    def profile
      super || Users::ClientProfile.new(first_name: "", last_name: "")
    end

    def settings
      super || Users::ClientSettings.new(
        currency: organization_currency,
        user: self
      )
    end

    def organization_currency
      return Organizations::DEFAULT_SCOPE["default_currency"] if organization.nil? || organization.scope.nil?

      organization.scope.content["default_currency"] || Organizations::DEFAULT_SCOPE["default_currency"]
    end
  end
end

# == Schema Information
#
# Table name: users_clients
#
#  id                                  :uuid             not null, primary key
#  access_count_to_reset_password_page :integer          default(0)
#  activation_state                    :string
#  activation_token                    :string
#  activation_token_expires_at         :datetime
#  crypted_password                    :string
#  deleted_at                          :datetime
#  email                               :string           not null
#  failed_logins_count                 :integer          default(0)
#  last_activity_at                    :datetime
#  last_login_at                       :datetime
#  last_login_from_ip_address          :string
#  last_logout_at                      :datetime
#  lock_expires_at                     :datetime
#  magic_login_email_sent_at           :datetime
#  magic_login_token                   :string
#  magic_login_token_expires_at        :datetime
#  reset_password_email_sent_at        :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  salt                                :string
#  unlock_token                        :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  organization_id                     :uuid
#
# Indexes
#
#  index_users_clients_on_activation_token           (activation_token) WHERE (deleted_at IS NULL)
#  index_users_clients_on_email                      (email) WHERE (deleted_at IS NULL)
#  index_users_clients_on_email_and_organization_id  (email,organization_id) UNIQUE
#  index_users_clients_on_magic_login_token          (magic_login_token) WHERE (deleted_at IS NULL)
#  index_users_clients_on_organization_id            (organization_id)
#  index_users_clients_on_reset_password_token       (reset_password_token) WHERE (deleted_at IS NULL)
#  index_users_clients_on_unlock_token               (unlock_token) WHERE (deleted_at IS NULL)
#  users_clients_activity                            (last_logout_at,last_activity_at) WHERE (deleted_at IS NULL)
#
