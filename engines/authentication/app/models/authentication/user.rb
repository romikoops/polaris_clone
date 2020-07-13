# frozen_string_literal: true

module Authentication
  class User < Users::User
    self.inheritance_column = :_sti_type_disabled
    authenticates_with_sorcery!

    validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }

    after_create :assign_default_group

    def self.authentication_scope
      where(id: memberships_ids).or(User.where(organization_id: organization_id))
    end

    def self.with_membership
      where(id: Organizations::Membership.select(:user_id).distinct)
    end

    def self.organization_id
      Organizations.current_id
    end

    def self.memberships_ids
      Organizations::Membership.select(:user_id).where(organization_id: organization_id)
    end

    def assign_default_group
      default_group = Groups::Group.find_by(organization_id: organization_id, name: "default")
      return unless default_group

      Groups::Membership.find_or_create_by(
        member: self,
        group: default_group
      )
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
