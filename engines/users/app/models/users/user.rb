# frozen_string_literal: true

module Users
  class User < Base
    self.inheritance_column = nil

    has_one :profile, inverse_of: :user, required: true, dependent: :destroy
    accepts_nested_attributes_for :profile, update_only: true

    has_one :settings, inverse_of: :user, required: true, dependent: :destroy
    accepts_nested_attributes_for :settings, update_only: true

    has_many :memberships, dependent: :destroy, inverse_of: :user
    accepts_nested_attributes_for :memberships

    has_many :organizations, through: :memberships

    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    acts_as_paranoid

    scope :from_current_organization, lambda {
      joins(:memberships).where(users_memberships: { organization_id: ::Organizations.current_id })
    }
  end
end

# == Schema Information
#
# Table name: users_users
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
#  type                                :string
#  unlock_token                        :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  organization_id                     :uuid
#
# Indexes
#
#  index_users_users_on_activation_token           (activation_token) WHERE (deleted_at IS NULL)
#  index_users_users_on_email                      (email) WHERE (deleted_at IS NULL)
#  index_users_users_on_email_and_organization_id  (email,organization_id) UNIQUE
#  index_users_users_on_email_and_type             (email,type) UNIQUE WHERE (organization_id IS NULL)
#  index_users_users_on_magic_login_token          (magic_login_token) WHERE (deleted_at IS NULL)
#  index_users_users_on_organization_id            (organization_id)
#  index_users_users_on_reset_password_token       (reset_password_token) WHERE (deleted_at IS NULL)
#  index_users_users_on_unlock_token               (unlock_token) WHERE (deleted_at IS NULL)
#  users_users_activity                            (last_logout_at,last_activity_at) WHERE (deleted_at IS NULL)
#
