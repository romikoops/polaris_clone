# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Client, type: :model do
  let(:user) { FactoryBot.build(:api_client) }

  let(:organization) { FactoryBot.create(:organizations_organization) }

  before do
    ::Organizations.current_id = organization.id
  end

  it "builds a valid user" do
    expect(user).to be_valid
  end

  context "when sorted by email" do
    let(:sort_by) { "email" }
    let!(:asc_user) { FactoryBot.create(:api_client, email: "aaa@itsmycargo.test", organization: organization) }
    let!(:desc_user) { FactoryBot.create(:api_client, email: "bbb@itsmycargo.test", organization: organization) }
    let(:sorted_users) { described_class.sorted_by(sort_by, direction) }

    context "when sorted by email asc" do
      let(:direction) { "ASC" }

      it "returns clients based on email in ascending order" do
        expect(sorted_users.map(&:id)).to eq([asc_user.id, desc_user.id])
      end
    end

    context "when sorted by email desc" do
      let(:direction) { "DESC" }

      it "returns clients based on email in descending order" do
        expect(sorted_users.map(&:id)).to eq([desc_user.id, asc_user.id])
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
