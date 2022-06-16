# frozen_string_literal: true

require "rails_helper"

module Users
  RSpec.describe User, type: :model do
    subject { FactoryBot.build(:users_user) }

    let!(:another_user) do
      FactoryBot.create(:users_user).tap do |user|
        FactoryBot.create(:users_membership, organization: another_organization, user: user)
      end
    end
    let(:another_organization) { FactoryBot.create(:organizations_organization, slug: "different_org") }

    it { is_expected.to be_valid }

    describe "#from_current_organization" do
      before do
        ::Organizations::Organization.current_id = another_organization.id
      end

      context "with organization_id as `another_organization` id" do
        it "returns `another_user` id" do
          expect(described_class.from_current_organization.ids).to match_array([another_user.id])
        end
      end
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
