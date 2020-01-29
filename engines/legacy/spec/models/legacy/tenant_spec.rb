# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Tenant, type: :model do
    let(:tenant) { FactoryBot.create(:legacy_tenant, :with_mot_emails) }

    describe '#subdomain' do
      it 'is deprecated' do
        expect(tenant.subdomain).to eq('demo')
      end
    end

    describe '#__subdomain' do
      it 'is deprecated' do
        expect(tenant.__subdomain).to eq('demo')
      end
    end

    describe '.email_for' do
      it 'it returns the email for the desired mode_of_transport' do
        expect(tenant.email_for(:sales, 'ocean')).to eq(tenant.emails.dig('sales', 'ocean'))
      end

      it 'it returns the general email when the desired mode_of_transport doesnt exist' do
        expect(tenant.email_for(:sales, 'plane')).to eq(tenant.emails.dig('sales', 'general'))
      end
    end

    context 'max dimensions bundles' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }

      describe '#max_dimensions' do
        it 'has max dimensions' do
          expect(tenant.max_dimensions).to eq general: { chargeable_weight: 0.1e5, dimension_x: 0.5e3, dimension_y: 0.5e3, dimension_z: 0.5e3, payload_in_kg: 0.1e5 }
        end
      end

      describe '#max_aggregate_dimensions' do
        it 'has max aggregated dimensions' do
          expect(tenant.max_aggregate_dimensions).to eq general: { chargeable_weight: 0.2177e5, dimension_x: 0.5e4, dimension_y: 0.5e4, dimension_z: 0.5e4, payload_in_kg: 0.2177e5 }
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
#  addresses   :jsonb
#  currency    :string           default("EUR")
#  email_links :jsonb
#  emails      :jsonb
#  name        :string
#  phones      :jsonb
#  scope       :jsonb
#  subdomain   :string
#  theme       :jsonb
#  web         :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
