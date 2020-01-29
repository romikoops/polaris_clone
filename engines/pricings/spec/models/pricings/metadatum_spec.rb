# frozen_string_literal: true

require 'rails_helper'

module Pricings
  RSpec.describe Metadatum, type: :model do
    let(:metadatum) { FactoryBot.build(:pricings_metadatum) }

    describe '#valid?' do
      it 'build valid object' do
        expect(metadatum).to be_valid
      end
    end
  end
end

# == Schema Information
#
# Table name: pricings_metadata
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  cargo_unit_id       :integer
#  charge_breakdown_id :integer
#  pricing_id          :uuid
#  tenant_id           :uuid
#
# Indexes
#
#  index_pricings_metadata_on_charge_breakdown_id  (charge_breakdown_id)
#  index_pricings_metadata_on_tenant_id            (tenant_id)
#
