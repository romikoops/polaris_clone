# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe User, type: :model do
    let(:user) { FactoryBot.build(:legacy_user) }
    let(:agency) { FactoryBot.build(:legacy_agency) }
    let(:role) { FactoryBot.create(:legacy_role, name: 'agent') }
    let(:agency_user) { FactoryBot.build(:legacy_user, company_name: nil, agency: agency, role: role) }
    let(:user_no_company) { FactoryBot.build(:legacy_user, company_name: nil, agency: nil) }

    describe '.full_name' do
      it 'returns the first and last name of the user' do
        expect(user.full_name).to eq('John Smith')
      end
    end

    describe '.full_name_and_company' do
      it 'returns the first and last name of the user' do
        expect(user.full_name_and_company).to eq('John Smith, ItsMyCargo')
      end
    end

    describe '.company_name' do
      it 'returns the property of model' do
        expect(user.company_name).to eq('ItsMyCargo')
      end

      it 'returns the agency name if it is null' do
        expect(agency_user.company_name).to eq(agency.name)
      end

      it 'returns null if company_name and agency are null' do
        expect(user_no_company.company_name).to eq(nil)
      end
    end

    describe '#pricing_id' do
      it 'get the princing id from agency if it is has agency role' do
        expect(agency_user.pricing_id).to eq(agency_user.agency.agency_manager_id)
      end

      it 'get the user id if it is in the agency group' do
        expect(user.pricing_id).to eq(user.id)
      end
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                                :bigint           not null, primary key
#  allow_password_change             :boolean          default(FALSE), not null
#  company_name                      :string
#  company_number                    :string
#  confirmation_sent_at              :datetime
#  confirmation_token                :string
#  confirmed_at                      :datetime
#  currency                          :string           default("EUR")
#  current_sign_in_at                :datetime
#  current_sign_in_ip                :string
#  deleted_at                        :datetime
#  email(MASKED WITH EmailAddress)   :string
#  encrypted_password                :string           default(""), not null
#  first_name(MASKED WITH FirstName) :string
#  guest                             :boolean          default(FALSE)
#  image                             :string
#  internal                          :boolean          default(FALSE)
#  last_name(MASKED WITH LastName)   :string
#  last_sign_in_at                   :datetime
#  last_sign_in_ip                   :string
#  nickname                          :string
#  optin_status                      :jsonb
#  phone(MASKED WITH Phone)          :string
#  provider                          :string           default("tenant_email"), not null
#  remember_created_at               :datetime
#  reset_password_sent_at            :datetime
#  reset_password_token              :string
#  sign_in_count                     :integer          default(0), not null
#  tokens                            :json
#  uid                               :string           default(""), not null
#  unconfirmed_email                 :string
#  vat_number                        :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  agency_id                         :integer
#  external_id                       :string
#  optin_status_id                   :integer
#  role_id                           :bigint
#  sandbox_id                        :uuid
#  tenant_id                         :integer
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role_id               (role_id)
#  index_users_on_sandbox_id            (sandbox_id)
#  index_users_on_tenant_id             (tenant_id)
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (role_id => roles.id)
#
