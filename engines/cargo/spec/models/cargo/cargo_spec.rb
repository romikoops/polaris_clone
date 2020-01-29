# frozen_string_literal: true

require 'rails_helper'

module Cargo
  RSpec.describe Cargo, type: :model do
    it_behaves_like 'aggregated cargo' do
      subject do
        cargo = FactoryBot.build(:cargo_cargo, units: [
                                   FactoryBot.build(:aggregated_unit, weight_value: 3000, volume_value: 1.3)
                                 ])
        cargo.validate
        cargo
      end
    end

    it_behaves_like 'multiple lcl units' do
      subject do
        cargo = FactoryBot.build(:cargo_cargo,
                                 units:
                                   FactoryBot.build_list(:lcl_unit, 5,
                                                         weight_value: 3000,
                                                         quantity: 2,
                                                         width_value: 1.20,
                                                         length_value: 0.80,
                                                         height_value: 1.40))
        cargo.validate
        cargo
      end
    end

    it_behaves_like 'updatable weight and volume' do
      subject do
        cargo = FactoryBot.build(:cargo_cargo, units: [
                                   FactoryBot.build(:lcl_unit, weight_value: 3000,
                                                               width_value: 1.20,
                                                               length_value: 0.80,
                                                               height_value: 1.40)
                                 ])
        cargo.validate
        cargo
      end
    end
  end
end

# == Schema Information
#
# Table name: cargo_cargos
#
#  id                         :uuid             not null, primary key
#  total_goods_value_cents    :integer          default(0), not null
#  total_goods_value_currency :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  quotation_id               :uuid
#  tenant_id                  :uuid
#
# Indexes
#
#  index_cargo_cargos_on_quotation_id  (quotation_id)
#  index_cargo_cargos_on_tenant_id     (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (quotation_id => quotations_quotations.id)
#
