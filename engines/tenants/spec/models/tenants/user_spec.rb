# frozen_string_literal: true

require 'rails_helper'

module Tenants
  RSpec.describe User, type: :model do
    context 'legacy_sync' do
      let(:legacy_user) { FactoryBot.build(:legacy_user) }
      it 'creates from legacy' do
        user = described_class.create_from_legacy(legacy_user)
        expect(user).to be_valid
      end
    end

    context 'instance methods' do
      let!(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
      let!(:currency) { FactoryBot.create(:legacy_currency) }
      let(:address) { FactoryBot.create(:legacy_address) }
      let(:company) { FactoryBot.create(:tenants_company, tenant: tenants_tenant, address: address) }
      let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base, company_name: 'ItsMyCargo') }
      let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
      let(:group_1) { FactoryBot.create(:tenants_group, tenant: tenants_tenant) }
      let!(:membership_1) { FactoryBot.create(:tenants_membership, member: tenants_user, group: group_1) }

      describe '.groups' do
        it 'returns the groups that the company is a member of' do
          expect(tenants_user.groups).to eq([group_1])
        end
      end

      describe '.verify_company' do
        it 'creates the company if it doesnt exist' do
          tenants_user.verify_company
          expect(tenants_user.company&.name).to eq('ItsMyCargo')
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: tenants_users
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
#  reset_password_email_sent_at        :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  salt                                :string
#  unlock_token                        :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  company_id                          :uuid
#  legacy_id                           :integer
#  sandbox_id                          :uuid
#  tenant_id                           :uuid
#
# Indexes
#
#  index_tenants_users_on_activation_token                     (activation_token)
#  index_tenants_users_on_email_and_tenant_id                  (email,tenant_id) UNIQUE
#  index_tenants_users_on_last_logout_at_and_last_activity_at  (last_logout_at,last_activity_at)
#  index_tenants_users_on_reset_password_token                 (reset_password_token)
#  index_tenants_users_on_sandbox_id                           (sandbox_id)
#  index_tenants_users_on_tenant_id                            (tenant_id)
#  index_tenants_users_on_unlock_token                         (unlock_token)
#
