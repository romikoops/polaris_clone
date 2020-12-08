require "rails_helper"

module Organizations
  RSpec.describe User, type: :model do
    let(:user) { FactoryBot.build(:organizations_user) }

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:asc_user) { FactoryBot.create(:organizations_user, organization: organization, email: "1@itsmycargo.com") }
    let(:desc_user) { FactoryBot.create(:organizations_user, organization: organization, email: "2@itsmycargo.com") }
    let(:sorted_users) { described_class.sorted_by(sort_by, direction) }

    before do
      ::Organizations.current_id = organization.id
    end

    it "builds a valid user" do
      expect(user).to be_valid
    end

    context "when sorted by company_name" do
      let(:company_1) { FactoryBot.create(:companies_company, organization: organization, name: "1") }
      let(:company_2) { FactoryBot.create(:companies_company, organization: organization, name: "2") }

      before do
        FactoryBot.create(:companies_membership, company: company_1, member: asc_user)
        FactoryBot.create(:companies_membership, company: company_2, member: desc_user)
      end

      let(:sort_by) { "company_name" }

      context "when sorted by company name asc" do
        let(:direction) { "ASC" }

        it "returns clients based on company name in ascending order" do
          expect(sorted_users).to eq([asc_user, desc_user])
        end
      end

      context "when sorted by company name desc" do
        let(:direction) { "DESC" }

        it "returns clients based on company name in descending order" do
          expect(sorted_users).to eq([desc_user, asc_user])
        end
      end
    end

    context "when sorted by email" do
      let(:sort_by) { "email" }

      context "when sorted by email asc" do
        let(:direction) { "ASC" }

        it "returns clients based on email in ascending order" do
          expect(sorted_users).to eq([asc_user, desc_user])
        end
      end

      context "when sorted by email desc" do
        let(:direction) { "DESC" }

        it "returns clients based on email in descending order" do
          expect(sorted_users).to eq([desc_user, asc_user])
        end
      end
    end

    context "when sorted by first name" do
      before do
        FactoryBot.create(:profiles_profile, user: asc_user, first_name: "1")
        FactoryBot.create(:profiles_profile, user: desc_user, first_name: "2")
      end

      let(:sort_by) { "first_name" }

      context "when sorted by first name asc" do
        let(:direction) { "ASC" }

        it "returns clients based on first name in ascending order" do
          expect(sorted_users).to eq([asc_user, desc_user])
        end
      end

      context "when sorted by first name desc" do
        let(:direction) { "DESC" }

        it "returns clients based on first name in descending order" do
          expect(sorted_users).to eq([desc_user, asc_user])
        end
      end
    end

    context "when sorted by last name" do
      before do
        FactoryBot.create(:profiles_profile, user: asc_user, last_name: "1")
        FactoryBot.create(:profiles_profile, user: desc_user, last_name: "2")
      end

      let(:sort_by) { "last_name" }

      context "when sorted by last name asc" do
        let(:direction) { "ASC" }

        it "returns clients based on last name in ascending order" do
          expect(sorted_users).to eq([asc_user, desc_user])
        end
      end

      context "when sorted by last name desc" do
        let(:direction) { "DESC" }

        it "returns clients based on last name in descending order" do
          expect(sorted_users).to eq([desc_user, asc_user])
        end
      end
    end

    context "when sorted by role" do
      before do
        Organizations::Membership.create(user: asc_user, organization: organization, role: "admin")
        Organizations::Membership.create(user: desc_user, organization: organization, role: "user")
      end

      let(:sort_by) { "role" }

      context "when sorted by role asc" do
        let(:direction) { "ASC" }

        it "returns clients based on role in ascending order" do
          expect(sorted_users).to eq([asc_user, desc_user])
        end
      end

      context "when sorted by role desc" do
        let(:direction) { "DESC" }

        it "returns clients based on role in descending order" do
          expect(sorted_users).to eq([desc_user, asc_user])
        end
      end
    end

    context "when sorted by phone" do
      before do
        FactoryBot.create(:profiles_profile, user: asc_user, phone: "1")
        FactoryBot.create(:profiles_profile, user: desc_user, phone: "2")
      end

      let(:sort_by) { "phone" }

      context "when sorted by phone asc" do
        let(:direction) { "ASC" }

        it "returns clients based on phone in ascending order" do
          expect(sorted_users).to eq([asc_user, desc_user])
        end
      end

      context "when sorted by phone desc" do
        let(:direction) { "DESC" }

        it "returns clients based on phone in descending order" do
          expect(sorted_users).to eq([desc_user, asc_user])
        end
      end

      context "without matching sort_by scope" do
        let(:sort_by) { "nonsense" }
        let(:direction) { "desc" }

        it "returns default direction" do
          expect { sorted_users }.to raise_error ArgumentError
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
#  index_users_users_on_conflict_organizations  (email,organization_id) UNIQUE WHERE ((type)::text = 'Organizations::User'::text)
#  index_users_users_on_conflict_users          (email) UNIQUE WHERE ((type)::text = 'Users::User'::text)
#  index_users_users_on_email                   (email) WHERE (deleted_at IS NULL)
#  index_users_users_on_magic_login_token       (magic_login_token) WHERE (deleted_at IS NULL)
#  index_users_users_on_organization_id         (organization_id)
#  index_users_users_on_reset_password_token    (reset_password_token) WHERE (deleted_at IS NULL)
#  index_users_users_on_unlock_token            (unlock_token) WHERE (deleted_at IS NULL)
#  users_users_activity                         (last_logout_at,last_activity_at) WHERE (deleted_at IS NULL)
#
