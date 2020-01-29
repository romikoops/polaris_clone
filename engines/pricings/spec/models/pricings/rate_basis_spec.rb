# frozen_string_literal: true

require 'rails_helper'

module Pricings
  RSpec.describe RateBasis, type: :model do
    context 'class_methods' do
      describe 'create_from_external_key' do
        it 'creates a new rate basis when one doesnt exist' do
          rb = ::Pricings::RateBasis.create_from_external_key('PER_SHIPMENT')
          expect(rb.internal_code).to eq('PER_SHIPMENT')
        end
        it 'returns the existsing rate basis if it exists' do
          erb = ::Pricings::RateBasis.create(external_code: 'PER_MBL', internal_code: 'PER_SHIPMENT')
          rb = ::Pricings::RateBasis.create_from_external_key('PER_MBL')
          expect(rb).to eq(erb)
        end
      end
      describe 'get_internal_key' do
        it 'returns the input rate basis when one doesnt exist' do
          rb = ::Pricings::RateBasis.get_internal_key('PER_SHIPMENT')
          expect(rb).to eq('PER_SHIPMENT')
        end
        it 'returns the existsing rate basis if it exists' do
          ::Pricings::RateBasis.create(external_code: 'PER_MBL', internal_code: 'PER_SHIPMENT')
          rb = ::Pricings::RateBasis.get_internal_key('PER_MBL')
          expect(rb).to eq('PER_SHIPMENT')
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: pricings_rate_bases
#
#  id            :uuid             not null, primary key
#  description   :string
#  external_code :string
#  internal_code :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sandbox_id    :uuid
#
# Indexes
#
#  index_pricings_rate_bases_on_external_code  (external_code)
#  index_pricings_rate_bases_on_sandbox_id     (sandbox_id)
#
