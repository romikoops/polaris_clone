# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::Client, type: :model do
  let(:user) { FactoryBot.build(:users_client) }

  it "builds a valid user" do
    expect(user).to be_valid
  end

  context "when the email isn't downcased" do
    let(:email) { "NoTcAsEdProPerLy@itsmycargo.test" }
    let(:user) { FactoryBot.build(:users_client, email: email).tap(&:valid?) }

    it "safely downcases the email prior to validation" do
      expect(user.email).to eq(email.downcase)
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
#  index_users_users_on_activation_token        (activation_token) WHERE (deleted_at IS NULL)
#  index_users_users_on_conflict_organizations  (email,organization_id) UNIQUE WHERE ((type)::text = 'Users::Client'::text)
#  index_users_users_on_conflict_users          (email) UNIQUE WHERE ((type)::text = 'Users::User'::text)
#  index_users_users_on_email                   (email) WHERE (deleted_at IS NULL)
#  index_users_users_on_magic_login_token       (magic_login_token) WHERE (deleted_at IS NULL)
#  index_users_users_on_organization_id         (organization_id)
#  index_users_users_on_reset_password_token    (reset_password_token) WHERE (deleted_at IS NULL)
#  index_users_users_on_unlock_token            (unlock_token) WHERE (deleted_at IS NULL)
#  users_users_activity                         (last_logout_at,last_activity_at) WHERE (deleted_at IS NULL)
#
