# frozen_string_literal: true

module Users
  class User < ApplicationRecord
    include PgSearch::Model

    pg_search_scope :search, against: %i[email], using: {
      tsearch: {prefix: true}
    }
    has_many :authentications, foreign_key: :user_id, dependent: :destroy
    accepts_nested_attributes_for :authentications

    validates :email, presence: true, uniqueness: {scope: :organization_id},
                      format: {with: URI::MailTo::EMAIL_REGEXP}

    before_destroy :destroy_memberships

    acts_as_paranoid

    has_paper_trail skip: %i[last_activity_at unlock_token magic_login_token reset_password_token activation_token]

    def groups
      company_ids = Companies::Membership.where(member: self).pluck(:company_id)
      Groups::Group.joins(:memberships)
        .where(groups_memberships: {member_id: [id] | company_ids})
    end

    def destroy_memberships
      Groups::Membership.where(member: self).destroy_all
      Companies::Membership.where(member: self).destroy_all
    end
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
