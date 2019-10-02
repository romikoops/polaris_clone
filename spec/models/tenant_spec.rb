# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenant, type: :model do
  context 'instance methods' do
    describe '.email_for' do
      let(:default_imc_email) { 'itsmycargodev@gmail.com' }
      let(:general_sales_email) { 'sales.general@demo.com' }
      let(:ocean_sales_email) { 'sales.ocean@demo.com' }

      let(:tenant) { create(:tenant) }
      let(:tenant_with_mot_emails) { create(:tenant, :with_mot_emails) }

      context 'wrong argument for branch param' do
        it 'returns nil if branch param is nil' do
          expect(tenant.email_for(nil)).to be_nil
        end

        it 'returns nil if branch param is a Hash' do
          expect(tenant.email_for({})).to be_nil
        end
      end

      context 'A non-existing branch is passed as argument' do
        it 'returns default IMC email' do
          expect(tenant.email_for('some_string')).to eq(default_imc_email)
        end
      end

      context 'A valid branch is passed as argument (no mot)' do
        it 'returns general email' do
          expect(tenant.email_for('sales')).to eq(general_sales_email)
        end
      end

      context 'A valid branch and a non existing mot is passed as argument' do
        it 'returns general email when a string is passed' do
          expect(tenant_with_mot_emails.email_for('sales', 'some_string')).to eq(general_sales_email)
        end

        it 'returns general email when a nil is passed' do
          expect(tenant_with_mot_emails.email_for('sales', nil)).to eq(general_sales_email)
        end
      end

      context 'A valid branch and valid mot is passed as argument' do
        it 'returns correct email' do
          expect(
            tenant_with_mot_emails.email_for('sales', 'ocean')
          ).to eq(ocean_sales_email)
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: tenants
#
#  id          :bigint           not null, primary key
#  theme       :jsonb
#  emails      :jsonb
#  subdomain   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  phones      :jsonb
#  addresses   :jsonb
#  name        :string
#  scope       :jsonb
#  currency    :string           default("EUR")
#  web         :jsonb
#  email_links :jsonb
#
